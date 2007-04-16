From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: Sun, 15 Apr 2007 23:43:03 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC09400A1@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070416063126.GB14641@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Jamie webb" <j@jwebb.sygneca.com>, netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2231 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282AbXDPGn1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 02:43:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070416063126.GB14641@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> tg3s never use the IOMMU on AMD systems with production kernels
> because they have a suitably large DMA mask. IOMMU is only used
> there to remap memory that doesn't fit a device's DMA mask.
> There is a debugging mode to force iommu always, but it is not used 
> unless you configure it specially.

We actually have one chip that uses a 32-bit mask, and some that use
a 40-bit mask.  But you're right, I don't know for a fact whether it
was IOMMU or not.  The corruption happened on 64-bit chunks and seemed
to have gone away after upgrading to the latest kernel, according to
the user.


