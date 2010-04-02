From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix ethernet driver for Octeon based Movidis
 hardware
Date: Thu, 01 Apr 2010 18:20:45 -0700 (PDT)
Message-ID: <20100401.182045.106908204.davem@davemloft.net>
References: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757151Ab0DBBUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:20:45 -0400
In-Reply-To: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu,  1 Apr 2010 18:17:53 -0700

> The Movidis X16 bootloader doesn't enable the mdio bus.  The first
> patch fixes this by enabling the mdio bus when the driver is
> initialized.
> 
> Also the addresses of the PHYs was unknown for this device.  The
> second patch adds the corresponding PHY addresses.
> 
> With both patches applied I can successfully use all eight Ethernet
> ports.
> 
> Please consider for 2.6.34.  Since Octeon is an embedded MIPS SOC it
> is unlikely to break the kernel for any workstations.  Any or all of
> these could be considered for merging via Ralf's linux-mips.org tree.

Ralf please merge this via your MIPS tree, thanks:

Acked-by: David S. Miller <davem@davemloft.net>
