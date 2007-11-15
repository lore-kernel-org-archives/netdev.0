From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] add bnx2x driver for BCM57710 - bnx2x.c
Date: Thu, 15 Nov 2007 15:10:17 -0800 (PST)
Message-ID: <20071115.151017.218398535.davem@davemloft.net>
References: <1195154386.24548.29.camel@lb-tlvb-eliezer.il.broadcom.com>
	<1195155983.24548.35.camel@lb-tlvb-eliezer.il.broadcom.com>
	<20071115150349.51e6d133@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezert@broadcom.com, netdev@vger.kernel.org, jeff@garzik.org,
	masbock@us.ibm.com, eilong@broadcom.com, mchan@broadcom.com,
	linuxram@us.ibm.com, poswald@novell.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763682AbXKOXKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:10:18 -0500
In-Reply-To: <20071115150349.51e6d133@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 15 Nov 2007 15:03:49 -0800

> 1. Please use dev_err() to help user figure out which board has problem:
> Not:
> 		printk(KERN_ERR PFX "Cannot register net device\n");
> Instead:
> 		dev_err(&pdev->dev, "cannot register net device\n");
 ...

Stephen, thanks for the feedback.

My plan is to add today's submitted BNX2X driver as-is, so any of
these fixups should be submitted relative to that.

Thanks.
