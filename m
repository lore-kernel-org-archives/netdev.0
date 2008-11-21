From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 17:57:22 +0100
Message-ID: <20081121165722.GD1386@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:22265 "EHLO
	IE1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbYKUQ5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:57:31 -0500
Content-Disposition: inline
In-Reply-To: <1227286492.4901.208.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 04:54:52PM +0000, David Woodhouse wrote:
> On Fri, 2008-11-21 at 17:26 +0100, Joerg Roedel wrote:
> > this patchset introduces code to debug drivers usage of the DMA-API.
> > Tests with hardware IOMMUs have shown several bugs in drivers
> > regarding the usage of that API.
> > Problems were found especially in network card drivers.
> 
> This is really useful -- but surely it shouldn't be x86-specific?
> 
> All the code except the hooks in the architecture's dma_map_single() et
> al functions could be generic, couldn't it?

Yes, in principle we could move most of it to generic code. There is
nothing architecture specific in it.
Anybody who prefers this to be arch/x86 before moving it to lib/?

Joerg

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

