From: Patrick McHardy <kaber@trash.net>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 07 Oct 2008 15:29:58 +0200
Message-ID: <48EB6456.2040601@trash.net>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb> <20081007124820.GG4606@ntm.vs.lam.cz> <200810071549.16647.denys@visp.net.lb> <48EB5C63.60501@trash.net> <20081007132800.GH4606@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45926 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551AbYJGNaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 09:30:06 -0400
In-Reply-To: <20081007132800.GH4606@ntm.vs.lam.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Milan Kocian wrote:
> It is a pity that vlan id will not be in interface name. It was 
> comfortable to have vlan id in interface name. 
> Any reason for changing naming schema ?

What has changed is that the kernel doesn't support the
naming policies for the netlink interface. I don't see any
need for that, you can simply do:

ip add link eth0 name eth0.1000 type vlan id 1000

or choose whatever different scheme you like.
