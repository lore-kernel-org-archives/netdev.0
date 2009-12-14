From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Mon, 14 Dec 2009 08:34:35 +0100
Message-ID: <4B25EA8B.1030507@grandegger.com>
References: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>	<4B2552C8.4090105@grandegger.com> <20091213.174020.26980813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, chripell@fsfe.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55140 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbZLNHf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 02:35:28 -0500
In-Reply-To: <20091213.174020.26980813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Sun, 13 Dec 2009 21:47:04 +0100
> 
>> DMA can be selected with the module parameter "mcp251x_enable_dma" and
>> is *off* by default. Therefore the driver does in principle not depend
>> on HAS_DMA but I'm not sure if it's worth to handle it with #idef's.
>> Christian? Any thought?
> 
> I still think it's a reasonable dependency.
> 
> You're not going to find this device on a s390 system. :-)

OK, we could change that on request.

Wolfgang.
