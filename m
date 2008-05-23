From: Rick Jones <rick.jones2@hp.com>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 10:44:10 -0700
Message-ID: <4837026A.6000702@hp.com>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr> <4836FB73.2010709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:2011 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbYEWRoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 13:44:15 -0400
In-Reply-To: <4836FB73.2010709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> FWIW you can just use ethtool to determine the slot address quickly
> in userspace. There's no real need to do this in the kernel.
> 
> # ethtool -i eth0
> driver: e1000e
> version: 0.2.0
> firmware-version: 1.3-0
> bus-info: 0000:00:19.0

And if it happens to be in a hotplug slot today with a suitable hotplug 
module (term?) loaded like acpiphp you can then map that to a more human 
friendly slot number/name.  In the future, once Alex Chiang's pci slots 
patches make it to mainline it will be possible even with non-hotplug slots.

netperf omni tests and a couple other tools try to find such mappings today.

rick jones
