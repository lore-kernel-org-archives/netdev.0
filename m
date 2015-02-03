From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net v2] cls_api.c: Fix dumping of non-existing actions' stats.
Date: Tue, 3 Feb 2015 10:10:20 -0800
Message-ID: <CAHA+R7Pnb1=rbhOTND6MygDM+oL7byMGFP5TmCxeNegb-o62zA@mail.gmail.com>
References: <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
	<20150203180518.GA3806@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50858 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965998AbbBCSKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 13:10:21 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so27130946iec.3
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 10:10:21 -0800 (PST)
In-Reply-To: <20150203180518.GA3806@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2015 at 10:05 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> In tcf_exts_dump_stats(), ensure that exts->actions is not empty befo=
re
> accessing the first element of that list and calling tcf_action_copy_=
stats()
> on it.  This fixes some random segvs when adding filters of type "bas=
ic" with
> no particular action.
>
> This also fixes the dumping of those "no-action" filters, which more =
often
> than not made calls to tcf_action_copy_stats() fail and consequently =
netlink
> attributes added by the caller to be removed by a call to nla_nest_ca=
ncel().
>
> Fixes: 33be62715991 ("net_sched: act: use standard struct list_head")
> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicat=
ions.fr>

Acked-by: Cong Wang <cwang@twopensource.com>

Thanks!
