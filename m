From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 07:43:26 +0100
Message-ID: <1320734606.8976.0.camel@edumazet-laptop>
References: <20111108061737.B04D236221@apps0.cs.toronto.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Siebenmann <cks@cs.toronto.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62240 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab1KHGnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 01:43:32 -0500
Received: by wyh15 with SMTP id 15so141429wyh.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 22:43:30 -0800 (PST)
In-Reply-To: <20111108061737.B04D236221@apps0.cs.toronto.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 01:17 -0500, Chris Siebenmann a =C3=A9=
crit :
> | Le lundi 07 novembre 2011 =C3=A0 11:21 -0500, Chris Siebenmann a =C3=
=A9crit :
> | > I have a weird problem where a GRE tunnel periodically won't tran=
smit
> | > some (TCP) packets, while at the same time it will transmit other=
s just
> | > fine. This is happening in the current kernel.org git head kernel=
 as
> | > well as earlier ones.
> [...]
> | Do you have any errors on :
> |=20
> | ip -s -d link show dev greXXXX
>=20
>  I do indeed. When the problem is happening, I see TX errors counting
> up one-for-one with packets that are not transmitted (and no RX
> errors). Otherwise I don't see any errors. The other end of the GRE
> tunnel shows no errors (TX or RX).
>=20
>  Further information: when the problem is not happening, SSH doesn't
> seem to transmit 500-data-octet packets during startup. Instead I see=
:
>=20
> 	IP 128.100.3.52.42538 > 128.100.3.51.ssh: Flags [.], seq 22:824, ack=
 22, win 91, options [nop,nop,TS val 1393299 ecr 29703771], length 802
>=20
>  I have also once seen an 'ip route show table cache' entry for a rou=
te
> through the GRE tunnel with 552-byte MTU listed:
>=20
> 	24.173.24.46 from 128.100.3.52 dev extun=20
> 	    cache  expires 21333540sec ipid 0x9e5c mtu 552
>=20
> I haven't been able to reproduce this. I have seen listed mtu figures
> in 'ip route show table cache' output routinely drop to 774, though.
>=20
> (I would like to have more data on this but inconveniently the proble=
m
> is now not reproducing itself. When it comes back I'll capture more
> information about route cache mtu values and error counts and see if
> there's anything interesting.)
>=20

OK, but could you please report the exact "ip -s -d link gre..."
output ?
