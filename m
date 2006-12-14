From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC] split NAPI from network device.
Date: Fri, 15 Dec 2006 07:01:23 +1100
Message-ID: <1166126484.31351.21.camel@localhost.localdomain>
References: <1165901258.11914.32.camel@localhost.localdomain>
	 <20061213113537.6baf410f@dxpl.pdx.osdl.net>
	 <1166042552.11914.188.camel@localhost.localdomain>
	 <20061213154635.1f284bf6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugene Surovegin <ebs@ebshome.net>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34330 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932509AbWLNUBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:01:38 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061213154635.1f284bf6@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 15:46 -0800, Stephen Hemminger wrote:
> Split off NAPI part from network device, this patch is build tested
> only! It breaks kernel API for network devices, and only three examples
> are fixed (skge, sky2, and tg3).
> 
> 1. Decomposition allows different NAPI <-> network device
>    Some hardware has N devices for one IRQ, others like MSI-X
>    want multiple receive's for one device.
> 
> 2. Cleanup locking with netpoll
> 
> 3. Change poll callback arguements and semantics
> 
> 4. Make softnet_data static (only in dev.c)

Thanks !

I'll give a go at adapting emac and maybe a few more when I get 5mn to
spare...

Ben.


