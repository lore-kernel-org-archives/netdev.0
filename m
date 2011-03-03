From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 2 Mar 2011 16:56:53 -0800
Message-ID: <20110302165653.4b854489@nehalam>
References: <20110302164114.2e110ea0@nehalam>
	<20110302.164333.116393112.davem@davemloft.net>
	<20110302164637.6651b34f@nehalam>
	<20110302.165009.200353108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50361 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551Ab1CCA4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 19:56:55 -0500
In-Reply-To: <20110302.165009.200353108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Mar 2011 16:50:09 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 2 Mar 2011 16:46:37 -0800
> 
> > The addresses (that matter) when VPN is up are:
> 
> I really need to know what addresses interfaces have the time of the
> __ip_dev_find() call which, if I'm not mistaken, is before the VPN is
> up.


-- 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 00:23:54:91:08:c2 brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:23:54:91:08:c1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::223:54ff:fe91:8c1/64 scope link 
       valid_lft forever preferred_lft forever
 ... several offline interfaces ...
10: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 0a:2d:54:7c:09:96 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.1/24 brd 192.168.100.255 scope global virbr0
    inet6 fe80::82d:54ff:fe7c:996/64 scope link 
       valid_lft forever preferred_lft forever
11: virbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 46:2c:c7:fd:45:e5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.99.1/24 brd 192.168.99.255 scope global virbr1
    inet6 fe80::442c:c7ff:fefd:45e5/64 scope link 
       valid_lft forever preferred_lft forever
