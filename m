From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing
 actions' stats.
Date: Wed, 04 Feb 2015 20:26:39 -0800 (PST)
Message-ID: <20150204.202639.1658647887362952988.davem@davemloft.net>
References: <20150203141059.GA25454@zenon.in.qult.net>
	<20150203173251.GB6246@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ignacy.gawedzki@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965090AbbBEE0k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:26:40 -0500
In-Reply-To: <20150203173251.GB6246@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
Date: Tue, 3 Feb 2015 18:32:51 +0100

> In tcf_exts_dump_stats(), ensure that exts->actions is not empty befo=
re
> accessing the first element of that list and calling tcf_action_copy_=
stats()
> on it.  This fixes some random segvs when adding filters of type "bas=
ic" with
> no particular action.
>=20
> This also fixes the dumping of those "no-action" filters, which more =
often
> than not made calls to tcf_action_copy_stats() fail and consequently =
netlink
> attributes added by the caller to be removed by a call to nla_nest_ca=
ncel().
>=20
> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>

Applied, thanks.
