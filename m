From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Sun, 04 Mar 2007 16:19:24 -0800 (PST)
Message-ID: <20070304.161924.55508971.davem@davemloft.net>
References: <200703021538.41284.dada1@cosmosbay.com>
	<20070302130210.57883edc@freekitty>
	<45E8A936.9050908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52053
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbXCEATZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 19:19:25 -0500
In-Reply-To: <45E8A936.9050908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 02 Mar 2007 23:46:14 +0100

> Stephen Hemminger a =E9crit :
> > You missed a couple of spots.
>=20
> Arg yes...
 ...
> > -	}
> > -	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
> > +	svsk->sk_sk->sk_stamp =3D (skb->tstamp.tv64 !=3D 0) ? skb->tstamp
> > +		: ktime_get_real();
>=20
> Well, if we want to stay in the spirit of old code, we probably want =
to use=20
> current_kernel_time() (+ timespec_to_ktime()), because its less expen=
sive.
>=20
> And also setting the skb tstamp, no ?

Can you guys cook up an integrated patch with all the missing cases
fixed up as desired, so I can add this to net-2.6.22, thanks?
