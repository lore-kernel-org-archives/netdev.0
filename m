From: David Miller <davem@davemloft.net>
Subject: Re: [FIB]: full_children & empty_children should be uint, not
 ushort
Date: Sun, 13 Jan 2008 22:32:05 -0800 (PST)
Message-ID: <20080113.223205.38618230.davem@davemloft.net>
References: <4788A17D.5070903@cosmosbay.com>
	<478A58BD.8010304@cosmosbay.com>
	<18314.35427.947982.424287@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, stephen.hemminger@vyatta.com,
	robert.olsson@its.uu.se, netdev@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750830AbYANGcF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 01:32:05 -0500
In-Reply-To: <18314.35427.947982.424287@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Sun, 13 Jan 2008 23:02:11 +0100

>=20
> Eric Dumazet writes:
>  > Eric Dumazet a =E9crit :
>  > > 4) full_children & empty_children being 'unsigned short',
>  > >    we probably are limited to 2^15 elements, but I could not
>  > >    find this limit enforced somewhere.
>=20
>  > Two fixes are possible : Enlarge full_children & empty_children to=
 32bits, or=20
>  > force a limit in code to never exceed 2^15 children in a tnode. I =
chose the=20
>  > first solution since it can be done with 0 memory cost on 64bit ar=
ches.
 ...
>  Thanks for spotting this. No we don't want put limits on the (root) =
node size.
>  You see the comment in code is correct so unsigned short are some le=
ftover from=20
>  old testing which could have hit us hard as the routing table slowly=
 grows.
 ...
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks everyone.
