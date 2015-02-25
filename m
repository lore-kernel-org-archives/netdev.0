From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing
 actions' stats.
Date: Tue, 24 Feb 2015 21:15:56 -0500 (EST)
Message-ID: <20150224.211556.2272859487035151829.davem@davemloft.net>
References: <20150203173251.GB6246@zenon.in.qult.net>
	<20150204.202639.1658647887362952988.davem@davemloft.net>
	<CAHA+R7MMdm_9D96kLdPAyWzH0JiHRc0nz7rrHcwHUTK-Ms=JOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ignacy.gawedzki@green-communications.fr, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbBYCP6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 21:15:58 -0500
In-Reply-To: <CAHA+R7MMdm_9D96kLdPAyWzH0JiHRc0nz7rrHcwHUTK-Ms=JOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <cwang@twopensource.com>
Date: Tue, 24 Feb 2015 16:20:42 -0800

> On Wed, Feb 4, 2015 at 8:26 PM, David Miller <davem@davemloft.net> wr=
ote:
>> From: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
>> Date: Tue, 3 Feb 2015 18:32:51 +0100
>>
>>> In tcf_exts_dump_stats(), ensure that exts->actions is not empty be=
fore
>>> accessing the first element of that list and calling tcf_action_cop=
y_stats()
>>> on it.  This fixes some random segvs when adding filters of type "b=
asic" with
>>> no particular action.
>>>
>>> This also fixes the dumping of those "no-action" filters, which mor=
e often
>>> than not made calls to tcf_action_copy_stats() fail and consequentl=
y netlink
>>> attributes added by the caller to be removed by a call to nla_nest_=
cancel().
>>>
>>> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communicati=
ons.fr>
>>
>> Applied, thanks.
>=20
> Dave, please queue this patch for -stable as well, if you haven't don=
e yet.
> It needs to backport back to 3.14.

Done.
