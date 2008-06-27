From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix IOMMU overflow checking in s2io.c
Date: Fri, 27 Jun 2008 01:32:36 -0400
Message-ID: <48647B74.8020207@garzik.org>
References: <20080618115836.GA18655@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56666 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180AbYF0Fck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:32:40 -0400
In-Reply-To: <20080618115836.GA18655@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Fix IOMMU overflow checking in s2io.c
> 
> s2io has IOMMU overflow checking, but unfortunately it is wrong.
> 
> It didn't use the standard macros, which meant that it only worked
> on POWER and SPARC because only those define DMA_ERROR_CODE. Convert it to 
> use the standard macros instead.
> 
> I also commented two more bugs in the IOMMU handling. It assumes
> that 0 DMA addresses cannot happen, but that's not true in all IOMMU setups.
> The information if a buffer has been already mapped needs to be stored
> elsewhere.
> 
> Didn't fix those because it needs careful checking of the buffer handling
> by the maintainers.
> 
> Cc: ram.vepa@neterion.com
> Cc: santosh.rastapur@neterion.com
> Cc: sivakumar.subramani@neterion.com
> Cc: sreenivasa.honnur@neterion.com
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

applied


