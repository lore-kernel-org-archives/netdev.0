From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] ip-route: don't hide routes with RTM_F_CLONED by
 default
Date: Mon, 04 May 2015 14:37:08 -0400 (EDT)
Message-ID: <20150504.143708.1105742826058228400.davem@davemloft.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
	<1428933661-8193-5-git-send-email-pavlix@pavlix.net>
	<20150504083751.7c38626b@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pavlix@pavlix.net, netdev@vger.kernel.org, psimerda@redhat.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbEDShO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:37:14 -0400
In-Reply-To: <20150504083751.7c38626b@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 4 May 2015 08:37:51 -0700

> On Mon, 13 Apr 2015 16:00:59 +0200
> Pavel =A6imerda <pavlix@pavlix.net> wrote:
>=20
>> From: Pavel =A6imerda <psimerda@redhat.com>
>>=20
>> Signed-off-by: Pavel =A6imerda <psimerda@redhat.com>
>> ---
>>  ip/iproute.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> I understand your concern, and it probably was a poor design choice i=
nitially.
>=20
> Since this will change the output for the default case, it will upset=
 some
> peoples expectations and potentially break scripts that screen scrape=
 the output
> of ip commands. Therefore I can't accept it at this time.
>=20
> Sorry for the delay, but I thought someone else would add more commen=
ts.
> Perhaps if you explained in more detail the motivation of why this is=
 an
> important problem I would reconsider change the behavior.

We definitely need to report routes created by caching/cloning separate=
ly
from the main FIB entries.

And I agree that even if we wanted to change behavior, the horse has
already left the barn on this one and therefore there is no way we can
change this now.
