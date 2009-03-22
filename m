From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH 1/2] drivers/net/ax88796.c: take IRQ flags from
	platform_device
Date: Sun, 22 Mar 2009 17:18:48 +0100
Message-ID: <20090322161848.GA22308@buzzloop.caiaq.de>
References: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:49744 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbZCVQSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 12:18:53 -0400
Content-Disposition: inline
In-Reply-To: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2009 at 05:12:40PM +0100, Daniel Mack wrote:
> This patch adds support to the ax88796 ethernet driver to take IRQ flags
> given by the platform_device definition.

Please note that in contrast to the version I posted here previously,
this patch does not use platform_get_irq_flags() anymore. Nobody seemed
interested in the patch I sent along to implement that in
drivers/base/platform.c, so I gather the flags manually from this driver
now, using platform_get_resource().

Daniel

