From: "Denys" <nuclearcat@nuclearcat.com>
Subject: Re: r8169 crash
Date: Sun, 18 Nov 2007 00:44:38 +0200
Message-ID: <20071117224224.M6133@nuclearcat.com>
References: <20071117053920.M40084@nuclearcat.com> <20071117220759.GA2862@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:46206 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbXKQWoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 17:44:54 -0500
In-Reply-To: <20071117220759.GA2862@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Before it happens on 2.6.22, i tried to attach good cable, plug-unplug, 
whatever, interface up/down - card still remains dead.

I try to plug cable to laptop with rtl8139 and pc with e100 - it is worked 
when i shake bad cable(interface was going up/down as well), and good cable 
also worked fine, and never crashed. On 2.6.22 i was able to reproduce it 
easily, but later i can't cause it is server in internet cafe, and customers 
going crazy.


On Sat, 17 Nov 2007 23:07:59 +0100, Francois Romieu wrote
> Denys <nuclearcat@nuclearcat.com> :
> [...]
> > After that i have.
> > Nov 15 22:11:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:11:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:12:01 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:12:13 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:12:25 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:12:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:12:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
> > Nov 15 22:13:01 vzone NETDEV WATCHDOG: eth1: transmit timed out
> 
> Is there a chance for you to verify that the network interface does
> not recover if a real cable is plugged at this point ?
> 
> -- 
> Ueimor


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

