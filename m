From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Fri, 13 Nov 2015 22:11:32 +0100
Message-ID: <20151113211132.GE20320@lunn.ch>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33308 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbbKMVLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 16:11:34 -0500
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 04:02:18PM +0000, Premkumar Jonnala wrote:
> Packet forwarding to/from bond interfaces is done in software.
> 
> This patch enables certain platforms to bridge traffic to/from
> bond interfaces in hardware.  Notifications are sent out when 
> the "active" slave set for a bond interface is updated in 
> software.  Platforms use the notifications to program the 
> hardware accordingly.

Hi Premkumar

I can think of three use cases of binding with hardware offload
engines:

1) External user ports of the switch are bonded together into a trunk.

2) Host Ethernet ports connected to the switch are bonded together so
you get double the bandwidth between the host and the switch.

3) In DSA setups where you have a cluster of switches, some switch
ports connect to other switch ports, so forming the cluster. You can
bond ports together to double the bandwidth between switches in the
cluster.

The requirements here are quite different in each case. 
Which of these uses cases are you trying to address?

      Thanks
	Andrew
