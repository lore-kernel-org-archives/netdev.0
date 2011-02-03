From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: non-symmetric Unix dgram sockets and poll
Date: Thu, 3 Feb 2011 10:45:42 +0200
Message-ID: <201102031045.43283.remi@remlab.net>
References: <20110202173640.2af412f0@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38580 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002Ab1BCIpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 03:45:46 -0500
Received: from basile.remlab.net (cs27069010.pp.htv.fi [89.27.69.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTPSA id 935B5400
	for <netdev@vger.kernel.org>; Thu,  3 Feb 2011 09:45:44 +0100 (CET)
In-Reply-To: <20110202173640.2af412f0@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 2 f=E9vrier 2011 19:36:40 Alban Crequy, vous avez =E9crit :
> Hi,
>=20
> I have 3 Unix dgram sockets (sockA, sockB, sockC):
> - sockA is connected to sockB.
> - sockB is connected to sockC.
> - sockC is not connected.
>=20
> SockA cannot send any message to sockB because
> net/unix/af_unix.c::unix_may_send() prevents it. Is there any reason =
for
> that restriction?

Yes, absolutely. When you connect() a socket, you expect to only *recei=
ve*=20
packets from the specified peer.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
