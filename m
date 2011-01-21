From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Fri, 21 Jan 2011 08:12:26 +0100
Message-ID: <1295593946.2613.52.camel@edumazet-laptop>
References: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jamie Heilman <jamie@audible.transient.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44850 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab1AUHMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:12:32 -0500
In-Reply-To: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 22:17 -0800, Jamie Heilman a =C3=A9crit=
 :
> With 2.6.38-rc1 when I run: arp -Ds 192.168.2.41 eth0 pub
> I see:
>=20
> RTNL: assertion failed at net/core/neighbour.c (589)
> Pid: 2330, comm: arp Not tainted 2.6.38-rc1-00132-g8d99641-dirty #1
> Call Trace:
>  [<c11ed339>] ? pneigh_lookup+0xc3/0x168
>  [<c1219f27>] ? arp_req_set+0x86/0x1d5
>  [<c11e74b5>] ? dev_get_by_name_rcu+0x72/0x7f
>  [<c121a1a3>] ? arp_ioctl+0x12d/0x22e
>  [<c121dfeb>] ? inet_ioctl+0x82/0xa7
>  [<c11d8ffc>] ? sock_ioctl+0x1b7/0x1db
>  [<c11d8e45>] ? sock_ioctl+0x0/0x1db
>  [<c108f02f>] ? do_vfs_ioctl+0x47c/0x4c5
>  [<c101803c>] ? do_page_fault+0x315/0x341
>  [<c11daaf3>] ? sys_socket+0x44/0x5a
>  [<c11dab71>] ? sys_socketcall+0x68/0x270
>  [<c108f0ab>] ? sys_ioctl+0x33/0x4b
>  [<c1002897>] ? sysenter_do_call+0x12/0x26
>=20
> Figured I'd Cc Eric as this could be related to commit 941666c2,
> "net: RCU conversion of dev_getbyhwaddr() and arp_ioctl()"
>=20
> Config attached, just in case (the uncommited change, in the tree thi=
s
> kernel was built from, is just Chuck Lever's recent nfs3xdr.c patch).

Thanks for the report, I am looking at this right now.



