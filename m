From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 5 Aug 2011 07:13:43 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FE464EFC2@MNEXMB2.qlogic.org>
References: <99737F4847ED0A48AECC9F4A1974A4B80FE464EF82@MNEXMB2.qlogic.org>
	<20110805.032606.1214964517719657458.davem@davemloft.net>
	<99737F4847ED0A48AECC9F4A1974A4B80FE464EF99@MNEXMB2.qlogic.org>
 <20110805.042755.2121843538632981106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:58325
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755958Ab1HEMNu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 08:13:50 -0400
In-Reply-To: <20110805.042755.2121843538632981106.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 05, 2011 4:58 PM
> 
> From: Amit Salecha <amit.salecha@qlogic.com>
> Date: Fri, 5 Aug 2011 06:04:10 -0500
> 
> > This is true, but problem is after fw recovery. So flow is
> > 1) vlan device added
> > 2) Driver program ip address of vlan device (through inet events)
> > 3) Fw recovery
> > 4) After fw recovery driver need to program ip addresses again which
> were already programmed.
> >    After fw recovery there won't be any inet/netdev event.
> >
> > Simple solution is to maintain those ip addresses in driver.
> 
> When you program the device, in response to inet events, maintain a
> software list in the driver that remembers the IP address state.
> 
> Then on FW recovery, walk the special list to reprogram the device.

Make sense. Will repost patch with above logic
-Thanks.

