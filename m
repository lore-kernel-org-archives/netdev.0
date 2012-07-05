From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [iproute2] display vlan configuration
Date: Thu, 05 Jul 2012 16:20:38 -0700
Message-ID: <4FF62146.9070702@intel.com>
References: <4FF61DE9.7000507@jetable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Fabien C." <kczy1jafrl3jpq1@jetable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:38901 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933323Ab2GEXUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 19:20:40 -0400
In-Reply-To: <4FF61DE9.7000507@jetable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/5/2012 4:06 PM, Fabien C. wrote:
> Hello,
>
> it looks like there is no way to show the vlan configuration with iproute (nor with any other tool apparently).
>
> This can lead to trouble since :
>   # ip link add link eth0 name eth2.333 type vlan id 444
>
> will create an interface that will show up like this with "ip link show" :
>   51: eth2.333@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>
> The only hint we have is the interface name, which may not be related to the vlan id we set earlier.

Here you need to show the details,

#ip -d link show dev eth2.333

 From my current setup,

# ip -d link show dev vlan0
33: vlan0@eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
     link/ether 00:1b:21:55:23:59 brd ff:ff:ff:ff:ff:ff
     vlan id 101 <REORDER_HDR>
