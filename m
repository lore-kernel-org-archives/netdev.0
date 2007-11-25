From: Alistair John Strachan <alistair@devzero.co.uk>
Subject: Re: 2.6.24-rc3, 4GB RAM, swiotlb, r8169, out of space
Date: Sun, 25 Nov 2007 01:48:31 +0000
Message-ID: <200711250148.31695.alistair@devzero.co.uk>
References: <200711242344.49958.alistair@devzero.co.uk> <20071125002510.GA30759@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.betherenow.co.uk ([87.194.0.68]:34701 "EHLO
	smtp1.bethere.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbXKYBse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 20:48:34 -0500
In-Reply-To: <20071125002510.GA30759@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 25 November 2007 00:25:10 Francois Romieu wrote:
> Alistair John Strachan <alistair@devzero.co.uk> :
> [...]
>
> > The "choke" affects other devices on the system too, notably libata,
> > which does not recover gracefully. In my logs, I see a stream of:
> >
> > DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0
> > DMA: Out of SW-IOMMU space for 7222 bytes at device 0000:04:00.0
>
> You are using jumbo frames, aren't you ?

Yes, 7200 byte frames. I'll certainly try out your patch and report back.

-- 
Cheers,
Alistair.

137/1 Warrender Park Road, Edinburgh, UK.
