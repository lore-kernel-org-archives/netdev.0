From: "Fabien C." <kczy1jafrl3jpq1@jetable.org>
Subject: [iproute2] display vlan configuration
Date: Fri, 06 Jul 2012 01:06:17 +0200
Message-ID: <4FF61DE9.7000507@jetable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:48706 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933237Ab2GEXGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 19:06:30 -0400
Received: from [10.3.5.9] (unknown [81.57.168.177])
	by smtp4-g21.free.fr (Postfix) with ESMTP id A044B4C8034
	for <netdev@vger.kernel.org>; Fri,  6 Jul 2012 01:06:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

it looks like there is no way to show the vlan configuration with iproute (nor with any other tool apparently). 

This can lead to trouble since : 
 # ip link add link eth0 name eth2.333 type vlan id 444

will create an interface that will show up like this with "ip link show" : 
 51: eth2.333@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN

The only hint we have is the interface name, which may not be related to the vlan id we set earlier. 

Is there any way to get that information? 

Thanks, 
Fabien 
