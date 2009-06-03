From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Addition of new device id (resend without
 pci_ids.h)
Date: Wed, 03 Jun 2009 14:44:56 -0700 (PDT)
Message-ID: <20090603.144456.01215273.davem@davemloft.net>
References: <4A269F6C.7030300@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751783AbZFCVoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:44:55 -0400
In-Reply-To: <4A269F6C.7030300@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Wed, 03 Jun 2009 12:06:04 -0400

> Add support for new ethernet device in the MCP89 chipset.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Just use the constant directly, please :-)

The new macro is completely superfluous.

Trust me, other drivers just use the PCI ID constant directly in their
tables too, and no animals were harmed by the experiment :-)
