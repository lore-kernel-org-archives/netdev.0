From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 2 Mar 2011 16:46:37 -0800
Message-ID: <20110302164637.6651b34f@nehalam>
References: <20110302162826.59f52c77@nehalam>
	<20110302164114.2e110ea0@nehalam>
	<20110302.164333.116393112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51864 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753934Ab1CCAqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 19:46:39 -0500
In-Reply-To: <20110302.164333.116393112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addresses (that matter) when VPN is up are:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:23:54:91:08:c1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::223:54ff:fe91:8c1/64 scope link 
       valid_lft forever preferred_lft forever
13: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UNKNOWN qlen 3
    link/ppp 
    inet 10.250.0.105 peer 10.255.254.0/32 scope global ppp0

This is with working 2.6.37.2
