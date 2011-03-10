From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Thu, 10 Mar 2011 10:15:54 +0000
Message-ID: <20110310101554.GD11273@n2100.arm.linux.org.uk>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com> <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:57743 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab1CJKQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:16:04 -0500
Content-Disposition: inline
In-Reply-To: <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 10:10:37AM +0000, Jamie Iles wrote:
> Rather than detecting whether we need to do a clk_get() and enable on
> the "hclk" based on the kernel configuration, add an extra field to the
> platform data.  This makes it cleaner to add more supported
> architectures without lots of ifdeffery.

Why not have the platform provide a dummy hclk if no real hclk exists?
