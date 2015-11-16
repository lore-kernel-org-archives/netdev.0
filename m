From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 06:15:23 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9AA08022@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
 <20151113211132.GE20320@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:56135 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbbKPGPY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 01:15:24 -0500
In-Reply-To: <20151113211132.GE20320@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Saturday, November 14, 2015 2:42 AM
> To: Premkumar Jonnala
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] bonding: Offloading bonds to hardware
> 
> On Thu, Nov 12, 2015 at 04:02:18PM +0000, Premkumar Jonnala wrote:
> > Packet forwarding to/from bond interfaces is done in software.
> >
> > This patch enables certain platforms to bridge traffic to/from
> > bond interfaces in hardware.  Notifications are sent out when
> > the "active" slave set for a bond interface is updated in
> > software.  Platforms use the notifications to program the
> > hardware accordingly.
> 
> Hi Premkumar
> 
> I can think of three use cases of binding with hardware offload
> engines:

Thank you for the comments Andrew. 

> 
> 1) External user ports of the switch are bonded together into a trunk.
> 
> 2) Host Ethernet ports connected to the switch are bonded together so
> you get double the bandwidth between the host and the switch.
> 
> 3) In DSA setups where you have a cluster of switches, some switch
> ports connect to other switch ports, so forming the cluster. You can
> bond ports together to double the bandwidth between switches in the
> cluster.
> 
> The requirements here are quite different in each case.
> Which of these uses cases are you trying to address?

I am looking primarily at case (1) above, where traffic is forwarded in hardware.
When bond interfaces are configured with some switch (hardware forwarded)
ports as slaves, the switching hardware needs to handle the traffic appropriately
based on where it's being received or sent.

Thanks,
-Prem


> 
>       Thanks
> 	Andrew
