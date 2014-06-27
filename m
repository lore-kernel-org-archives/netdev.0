From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 2/2] ipv6:  Allow accepting RA from local IP
 addresses.
Date: Fri, 27 Jun 2014 08:24:13 +0200
Message-ID: <1403850253.3928.4.camel@localhost>
References: <1403644488-21709-1-git-send-email-greearb@candelatech.com>
	 <1403644488-21709-2-git-send-email-greearb@candelatech.com>
	 <53A9FA0A.70902@yoshifuji.org> <53AA3FB2.3080204@candelatech.com>
	 <53AB6E32.6010907@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	YOSHIFUJI Hideaki <hideaki@yoshifuji.org>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI =?UTF-8?Q?Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38644 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752476AbaF0GYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 02:24:17 -0400
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 4534A21D28
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 02:24:17 -0400 (EDT)
In-Reply-To: <53AB6E32.6010907@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Do, 2014-06-26 at 09:49 +0900, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=
=8B=B1=E6=98=8E wrote:
> >> (2014/06/25 6:14), greearb@candelatech.com wrote:
> >>> From: Ben Greear <greearb@candelatech.com>
> >>>
> >>> This can be used in virtual networking applications, and
> >>> may have other uses as well.  The option is disabled by
> >>> default, so no change to current operating behaviour
> >>
> >>                                     standard compliant behavior?
> >
> > I've no idea.  Can you point me to the proper standard (and
> > pertinent section)?
>=20
> I was wrong.
>=20
> I found this code was added by commit 9f56220 ("ipv6: Do not
> use routes from locally generated RAs") to fix behavior when
> accept_ra =3D=3D 2.
>=20
> But I do not understand why it is not enough to restrict local
> address on receiving interface.
>=20
> Andi, would you explain?

Wouldn't we alter existing behaviour in case someone connects several
NICs in a router to the same network while only running radvd on one
interface. Additional addresses would show up where prior none would
have.

I am in favor of checking all addresses in the current namespace.

Greetings,
Hannes
