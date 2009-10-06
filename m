From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on interrupt context.
Date: Mon, 5 Oct 2009 23:23:01 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16329@nekter>
References: <Pine.GSO.4.10.10910050757300.9377-100000@guinness> <20091005.053759.74765905.davem@davemloft.net> <78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter> <4ACAB72A.3080802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:39752 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033AbZJFDXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 23:23:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4ACAB72A.3080802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ramkrishna Vepa a =E9crit :
> > [Ram] Right, but why have the additional step of saving and restori=
ng
> > the flags while in the interrupt context?
> >
>=20
> It costs about the same thing than testing two times in_interrupt()
>=20
> pushf
> pop register
> test iflag,register
> je ...
>=20
>=20
> In the end, original code is shorter and faster.
[Ram] Got it. We'll remove this patch from the patch set.

Ram
