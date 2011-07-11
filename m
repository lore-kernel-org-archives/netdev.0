From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: recommended way to support duplicate IP addresses on different VLANs?
Date: Mon, 11 Jul 2011 18:04:25 +0300
Message-ID: <201107111804.26500.remi@remlab.net>
References: <4E1B0F86.2040508@mail.usask.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Friesen <cbf123@mail.usask.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38375 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757778Ab1GKPEb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 11:04:31 -0400
In-Reply-To: <4E1B0F86.2040508@mail.usask.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 17:58:14 Chris Friesen, vous avez =E9crit :
> Hi all,
>=20
> We've got a server that sits on multiple VLANs.  Each VLAN is segrega=
ted
> and doesn't know about the others.  The IP address ranges in each of =
the
> VLANs may overlap, and the server may be assigned the same IP address=
 in
> multiple VLANs.
>=20
> We've got a messy solution now involving unique internal addresses an=
d
> NATing between those and the duplicate external addresses, but I'm
> wondering if there is a cleaner way to handle this.
>=20
> It seems like network namespaces would work, but it would require
> multiple instances of our software which is a dealbreaker.
>=20
> Is there any other way to deal with this scenario?

Namespace file descriptors if/when they get accepted.

Or then binding sockets to devices (SO_BINDTODEVICE) might work.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
