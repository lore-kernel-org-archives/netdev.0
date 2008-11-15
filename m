From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH stable] r8169: Fix MII compilation error
Date: Fri, 14 Nov 2008 21:07:32 -0800
Message-ID: <20081115050732.GA26468@kroah.com>
References: <200811141629.32474.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51502 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750847AbYKOFQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 00:16:10 -0500
Content-Disposition: inline
In-Reply-To: <200811141629.32474.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 04:29:32PM +0100, Michael Buesch wrote:
> This fixes a compilation error (undefined MII symbols), if
> CONFIG_MII is not selected.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> ---
> 
> This fix already is in Linus' tree and I think it's a -stable candidate,
> as I just hit the bug while trying to compile 2.6.27.6.

Thanks, I just added commit b73724921d906 to the queue instead.

greg k-h
