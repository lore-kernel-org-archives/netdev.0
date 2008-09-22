From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: routing PF_PACKET sockets
Date: Mon, 22 Sep 2008 17:04:09 +0300
Message-ID: <200809221704.09530.remi.denis-courmont@nokia.com>
References: <3f847c820809211610n731b0090wb6a9f94a3514f455@mail.gmail.com> <5c4c427193d751928b131d43ab66879f@chewa.net> <3f847c820809220639y609470b6x9b2602cba24a0589@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ext =?iso-8859-1?q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:44280 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbYIVOEZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 10:04:25 -0400
In-Reply-To: <3f847c820809220639y609470b6x9b2602cba24a0589@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 September 2008 16:39:59 ext Ra=FAl Hern=E1ndez, you wrote:
> Just to clarify it a bit more; Suppose that a user app has two
> PF_PACKET sockets (SOCK_RAW) over eth0 and eth1 (to ensure redundancy=
)
> to send data to the network. In case eth0 is down, it would be
> useless, for example, move the routing table entries which reference
> eth0 to eth1 as the app which sends data to the network bypasses any
> routing policy (I think this would do if my app used standard tcp
> sockets).

If eth0 really goes down, your eth0 socket will receive ENETDOWN error.

Routing tables entries for a down interface are automatically disabled,=
 but=20
you would not care since your PF_PACKET sockets bypass these.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
