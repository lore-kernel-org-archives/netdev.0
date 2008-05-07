From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] am79c961a: use netstats in net_device structure
Date: Wed, 7 May 2008 22:30:03 +0100
Message-ID: <20080507213003.GF19814@flint.arm.linux.org.uk>
References: <481F7C14.7040909@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:34543 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbYEGVaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:30:16 -0400
Content-Disposition: inline
In-Reply-To: <481F7C14.7040909@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2008 at 12:28:52AM +0300, Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> Kill am79c961_getstats function, because by default it is used
> identical internal_stats function from net/core/dev.c
> Don't clear statistics when opening device.
> 
> Haven't tried to compile it. Need ack from ARM people!
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
