From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [stable] [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan
 packets when vid not used.
Date: Tue, 07 Dec 2010 21:50:26 +0100
Message-ID: <1291755026.5324.3.camel@edumazet-laptop>
References: <1289251381-6671-1-git-send-email-jesse@nicira.com>
	 <20101207195019.GP13189@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, stable@kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47458 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab0LGUue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 15:50:34 -0500
Received: by wyb28 with SMTP id 28so331313wyb.19
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 12:50:33 -0800 (PST)
In-Reply-To: <20101207195019.GP13189@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 d=C3=A9cembre 2010 =C3=A0 11:50 -0800, Greg KH a =C3=A9crit=
 :
> On Mon, Nov 08, 2010 at 01:23:01PM -0800, Jesse Gross wrote:
> > Normally hardware accelerated vlan packets are quickly dropped if
> > there is no corresponding vlan device configured.  The one exceptio=
n
> > is promiscuous mode, where we allow all of these packets through so
> > they can be picked up by tcpdump.  However, this behavior causes a
> > crash if we actually try to receive these packets.  This fixes that
> > crash by ignoring packets with vids not corresponding to a configur=
ed
> > device in the vlan hwaccel routines and then dropping them before t=
hey
> > get to consumers in the network stack.
> >=20
> > This patch applies only to 2.6.36 stable.  The problem was introduc=
ed
> > in that release and is already fixed by larger changes to the vlan
> > code in 2.6.37.
>=20
> Applied, thanks.
>=20

Oh well, which version ?

A new version of the patch was submitted 6 days ago .

http://patchwork.ozlabs.org/patch/73791/

Thanks




