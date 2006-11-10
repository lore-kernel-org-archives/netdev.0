From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Fri, 10 Nov 2006 09:37:15 -0800
Message-ID: <20061110093715.0aadd791@freekitty>
References: <200611101609.21333@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51871 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161891AbWKJRh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 12:37:26 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200611101609.21333@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 16:09:20 +0000
Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:

> [NET/IPv4]: Support for the UDP-Lite protocol (RFC 3828)
> 
> This adds support for UDP-Lite to the IPv4 stack, provided as an extension
> to the existing UDPv4 code:
> 	* generic routines are all located in net/ipv4/udp.c
> 	* UDP-Lite specific routines are in net/ipv4/udplite.c
> 	* MIB/statistics support in /proc/net/snmp and /proc/net/udplite
> 	* shared API with extensions for partial checksum coverage
> 	* consolidation of shared code
> 
> 

This code is does too much inlining (like existing network code).
Should it be made configurable?



-- 
Stephen Hemminger <shemminger@osdl.org>
