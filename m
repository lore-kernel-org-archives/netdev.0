From: Chris Wedgwood <cw@f00f.org>
Subject: Re: skge dysfunction on Amd X2 machine with 4GB memory
Date: Mon, 19 Feb 2007 23:15:02 -0800
Message-ID: <20070220071502.GA5081@tuatara.stupidest.org>
References: <20070211145755.GW3438@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.sbc.mail.mud.yahoo.com ([68.142.198.206]:39250 "HELO
	smtp107.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S964826AbXBTHVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 02:21:43 -0500
Content-Disposition: inline
In-Reply-To: <20070211145755.GW3438@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 11, 2007 at 04:57:55PM +0200, Matti Aarnio wrote:

> With the skge driver there seems to be some sort of problem to work
> in a system with memory above the 4 GB of PCI address space.

The chipset (apparently) doesn't deal with bus addresses over 4GB even
though the MAC does.

I guess the right way to fix this long term is to detect systems with
these chips and mask the dma_mask globally (or if you're clever per
bus)?

