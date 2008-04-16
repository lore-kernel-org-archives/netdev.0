From: Kostya B <bkostya@hotmail.com>
Subject: RE: netif_needs_gso behavior
Date: Wed, 16 Apr 2008 14:02:56 +0000
Message-ID: <BAY121-W6E46148E896AA4607937CB6EA0@phx.gbl>
References: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
 <20080416.013810.214799502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s12.bay0.hotmail.com ([65.54.246.84]:37305 "EHLO
	bay0-omc1-s12.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754176AbYDPOJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 10:09:05 -0400
In-Reply-To: <20080416.013810.214799502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----------------------------------------
> Date: Wed, 16 Apr 2008 01:38:10 -0700
> To: bkostya@hotmail.com
> CC: netdev@vger.kernel.org
> Subject: Re: netif_needs_gso behavior
> From: davem@davemloft.net
> 
> From: Kostya B 
> Date: Tue, 15 Apr 2008 16:52:20 +0000
> 
>> Please help me to understand why != CHECKSUM_PARTIAL packet requires gso? In the case of TCP it is ok, however UDP could be normally unchecked.
> 
> What exactly is the problem?  The UDP USO output paths set
> CHECKSUM_PARTIAL just like the TCP TSO ones do, so the test will pass
> for them.
> 
Not always, see udp4_hwcsum_outgoing()
In the case when socket queue contains several packets, the csum is reset.
_________________________________________________________________
Explore the seven wonders of the world
http://search.msn.com/results.aspx?q=7+wonders+world&mkt=en-US&form=QBRE
