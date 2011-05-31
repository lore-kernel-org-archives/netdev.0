From: Andrew Beverley <andy@andybev.com>
Subject: Re: IFB and iptables
Date: Tue, 31 May 2011 21:33:27 +0100
Message-ID: <1306874007.5439.13.camel@andybev-desktop>
References: <BANLkTimzL0_w=+CvbFNxNS=wAOZ61CrrdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?J=E9r=F4me?= Poulin <jeromepoulin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earth.simplelists.com ([89.16.184.171]:44122 "EHLO
	earth.simplelists.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758408Ab1EaUjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 16:39:41 -0400
In-Reply-To: <BANLkTimzL0_w=+CvbFNxNS=wAOZ61CrrdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-25 at 18:21 -0400, J=C3=A9r=C3=B4me Poulin wrote:
> Hi,
>=20
> I'm trying to convert my IMQ based script to use the IFB device inste=
ad.
> Things appear to work quite right however the u32 classifier isn't
> aware of any connection tracking and I was wondering if it is at all
> possible to use match from iptables like layer7 when you use the IFB
> device?

It depends where you are attaching your IFB device. Unlike IMQ, IFB can
only be hooked on an interface (IMQ can be hooked between iptables
chains). Therefore, if you are doing it on the ingress interface,
traffic will not have been connection-tracked. Off the top of my head,
it should work on egress though.

Andy


