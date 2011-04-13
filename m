From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Linux L4-Load Balancing with ECMP
Date: Wed, 13 Apr 2011 17:24:10 +0200
Message-ID: <201104131724.10822.christoph.paasch@uclouvain.be>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gregory Detal <gregory.detal@uclouvain.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:41067 "EHLO
	smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504Ab1DMPfv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 11:35:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

we were trying to do L4-load-balancing with the Linux Kernel (by config=
uring=20
multiple nexthops for the default-route) , and were surprised to see th=
at the=20
Linux Kernel load-balances the traffic based only on the IP-addresses a=
nd does=20
not consider the 5-tuple, when forwarding the traffic.

As L4 load-balancing with ECMP is quite common, I was wondering, if it =
has=20
ever been considered to include this in the Kernel?
Or, what are the reasons that it is not inside?

Thanks,
Christoph Paasch

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
