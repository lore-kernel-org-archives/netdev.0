From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.24-rc3, 4GB RAM, swiotlb, r8169, out of space
Date: Sun, 25 Nov 2007 01:25:10 +0100
Message-ID: <20071125002510.GA30759@electric-eye.fr.zoreil.com>
References: <200711242344.49958.alistair@devzero.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alistair John Strachan <alistair@devzero.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43597 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753036AbXKYA2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 19:28:13 -0500
Content-Disposition: inline
In-Reply-To: <200711242344.49958.alistair@devzero.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alistair John Strachan <alistair@devzero.co.uk> :
[...]
> The "choke" affects other devices on the system too, notably libata, which 
> does not recover gracefully. In my logs, I see a stream of:
> 
> DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0
> DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0

You are using jumbo frames, aren't you ?

-- 
Ueimor
