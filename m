From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ll_temac: fix checksum offload logic
Date: Wed, 26 May 2010 20:45:17 -0700 (PDT)
Message-ID: <20100526.204517.35032653.davem@davemloft.net>
References: <1274894959-27473-1-git-send-email-john.linn@xilinx.com>
	<0690e798-1e5e-4416-90dc-04a9df16600f@SG2EHSMHS005.ehs.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	brian.hill@xilinx.com
To: john.linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757028Ab0E0DpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 23:45:10 -0400
In-Reply-To: <0690e798-1e5e-4416-90dc-04a9df16600f@SG2EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aFrom: John Linn <john.linn@xilinx.com>
Date: Wed, 26 May 2010 11:29:19 -0600

> The current checksum offload code does not work and this corrects
> that functionality. It also updates the interrupt coallescing
> initialization so than there are fewer interrupts and performance
> is increased.
> 
> Signed-off-by: Brian Hill <brian.hill@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>

Applied, although I changed "temac_features" to be explicitly
"unsigned int" instead of just plain "unsigned"

