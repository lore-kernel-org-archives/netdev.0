From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [Bonding-devel] bonding inside a bridge does not work when using
 arp monitoring
Date: Sat, 26 Mar 2011 13:20:22 +0100
Message-ID: <4D8DDA06.4040704@gmail.com>
References: <1300302933.1462.5.camel@bordalnx>  <4D8121EF.3030200@free.fr> <1300914794.32252.68.camel@bordalnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>,
	Bridge <bridge@lists.linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Leonardo Borda <leonardo.borda@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32812 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab1CZMU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 08:20:27 -0400
Received: by wwa36 with SMTP id 36so2235029wwa.1
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2011 05:20:26 -0700 (PDT)
In-Reply-To: <1300914794.32252.68.camel@bordalnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/03/2011 22:13, Leonardo Borda a =C3=A9crit :
> Hi Nicolas,
>
> Thank you for answering my question.
> Actually this is what I want to achieve:
>
> eth0----+               +----bond0.100----br0-100---{+virtual machine=
s
>            |             |
>            +----bond0----+----br0---(LAN)
>            |             |
> eth1----+               +----bond0.200----br0-200---{+virtual machine=
s

Hi Leonardo,

I'm not sure recent kernels allow for a given interface to be a port fo=
r a bridge and the base=20
interface for vlan interfaces at the same time. This might be particula=
rly true for 2.6.38 or=20
2.6.38+, because of the new rx_handler usage.

cc: netdev and Jiri Pirko, for advices. For the history of the thread, =
see:

http://sourceforge.net/mailarchive/forum.php?thread_name=3D1300914794.3=
2252.68.camel%40bordalnx&
forum_name=3Dbonding-devel

> br0 -->  br0 in my understanding is an untagged vlan therefore it
> provides access to my LAN. So i am able to access that server from my
> internal network.
> br0-100 and br0-200 ->  Vlans over a bridged interface will allow me =
to
> have many virtual machines in the same vlan on each bridged interface=
=2E
>
> I am misunderstanding concepts, maybe?
> If you need to do further tests I have a test environment ready for u=
se.
>
> Leonardo
