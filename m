From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 1/2] net: implement a SO_PROTOCOL getsockoption
Date: Wed, 5 Aug 2009 12:28:49 +0300
Message-ID: <200908051228.50082.remi.denis-courmont@nokia.com>
References: <1249406909-24161-1-git-send-email-jengelh@medozas.de> <200908050935.03272.remi.denis-courmont@nokia.com> <alpine.LSU.2.00.0908051042180.28374@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:23674 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933678AbZHEJ33 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 05:29:29 -0400
In-Reply-To: <alpine.LSU.2.00.0908051042180.28374@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 August 2009 11:45:29 ext Jan Engelhardt wrote:
> On Wednesday 2009-08-05 08:35, R=C3=A9mi Denis-Courmont wrote:
> >On Tuesday 04 August 2009 20:28:28 ext Jan Engelhardt wrote:
> >> Similar to SO_TYPE returning the socket type, SO_PROTOCOL allows t=
o
> >> retrieve the protocol used with a given socket.
> >
> >You can easily infer the protocol family from the address family fro=
m
> >getsockname().
>
> As far as I remember, what you can get from getsockname is the
> domain type (AF_*/PF_*) through struct sockaddr->sa_family.
> Did you mean that?

Yes. It's almost like SO_DOMAIN but more portable and uglier.

> Though SO_PROTOCOL and SO_DOMAIN go nicely along with SO_TYPE.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

