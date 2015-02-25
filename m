From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing actions' stats.
Date: Tue, 24 Feb 2015 16:20:42 -0800
Message-ID: <CAHA+R7MMdm_9D96kLdPAyWzH0JiHRc0nz7rrHcwHUTK-Ms=JOA@mail.gmail.com>
References: <20150203141059.GA25454@zenon.in.qult.net>
	<20150203173251.GB6246@zenon.in.qult.net>
	<20150204.202639.1658647887362952988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:35725 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbbBYAUn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 19:20:43 -0500
Received: by iecrl12 with SMTP id rl12so725062iec.2
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 16:20:43 -0800 (PST)
In-Reply-To: <20150204.202639.1658647887362952988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 8:26 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communications.fr>
> Date: Tue, 3 Feb 2015 18:32:51 +0100
>
>> In tcf_exts_dump_stats(), ensure that exts->actions is not empty bef=
ore
>> accessing the first element of that list and calling tcf_action_copy=
_stats()
>> on it.  This fixes some random segvs when adding filters of type "ba=
sic" with
>> no particular action.
>>
>> This also fixes the dumping of those "no-action" filters, which more=
 often
>> than not made calls to tcf_action_copy_stats() fail and consequently=
 netlink
>> attributes added by the caller to be removed by a call to nla_nest_c=
ancel().
>>
>> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communica=
tions.fr>
>
> Applied, thanks.

Dave, please queue this patch for -stable as well, if you haven't done =
yet.
It needs to backport back to 3.14.

Thanks!
