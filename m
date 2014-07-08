From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] defxx: Fixes for 64-bit host support
Date: Tue, 08 Jul 2014 15:30:58 -0700 (PDT)
Message-ID: <20140708.153058.1645455335179932732.davem@davemloft.net>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Coerver@ll.mit.edu
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaGHWa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 18:30:59 -0400
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sat, 5 Jul 2014 15:14:13 +0100 (BST)

>  This mini patch series addresses issues with 64-bit host support for FDDI 
> interface boards supported by the defxx driver where DMA mapping 
> synchronisation is required on swiotlb systems.  While PDQ, the DMA engine 
> chip used with these boards, supports 48-bit addressing that would 
> normally suffice for typical 64-bit systems in existence, the host bus 
> interface chips used by individual implementations have their limitations 
> as follows:

Series applied to net-next, thanks.
