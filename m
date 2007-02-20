From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skge dysfunction on Amd X2 machine with 4GB memory
Date: Tue, 20 Feb 2007 11:50:29 -0800
Message-ID: <20070220115029.7b6b7e66@freekitty>
References: <20070211145755.GW3438@mea-ext.zmailer.org>
	<20070220071502.GA5081@tuatara.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matti Aarnio <matti.aarnio@zmailer.org>, netdev@vger.kernel.org
To: Chris Wedgwood <cw@f00f.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45849 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030373AbXBTTun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:50:43 -0500
In-Reply-To: <20070220071502.GA5081@tuatara.stupidest.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Feb 2007 23:15:02 -0800
Chris Wedgwood <cw@f00f.org> wrote:

> On Sun, Feb 11, 2007 at 04:57:55PM +0200, Matti Aarnio wrote:
> 
> > With the skge driver there seems to be some sort of problem to work
> > in a system with memory above the 4 GB of PCI address space.
> 
> The chipset (apparently) doesn't deal with bus addresses over 4GB even
> though the MAC does.
> 
> I guess the right way to fix this long term is to detect systems with
> these chips and mask the dma_mask globally (or if you're clever per
> bus)?


This needs to be done in via PCI quirks blacklisting. The driver has no
real way to test it.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
