From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 15:49:16 +0300
Message-ID: <200810071549.16647.denys@visp.net.lb>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb> <20081007124820.GG4606@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:44565 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbYJGMvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:51:22 -0400
In-Reply-To: <20081007124820.GG4606@ntm.vs.lam.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 07 October 2008, Milan Kocian wrote:
> hello,
>
> btw. How can I see vlan id on device ?
> After:
> # ip l a l eth0 type vlan id 100
> # ip a
> I see:
>
> 64: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>     link/ether 00:16:d3:3e:4e:b9 brd ff:ff:ff:ff:ff:ff
>
> No vlan id in interface name ?
>
> # ip -V
> ip utility, iproute2-ss080725
>
> regards,
Use flag -d
rich ip # ./ip -d l show dev vlan0
31: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:1e:8c:89:78:af brd ff:ff:ff:ff:ff:ff
    vlan id 100 <REORDER_HDR>
