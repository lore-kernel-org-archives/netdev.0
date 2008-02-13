From: maximilian attems <max@stro.at>
Subject: Re: [PATCH] [IRDA] irda_init() nuke useless debug printk
Date: Wed, 13 Feb 2008 11:51:58 +0100
Message-ID: <20080213105158.GA15544@stro.at>
References: <1202812247-6878-1-git-send-email-max@stro.at> <20080212.181742.150703641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:49392 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757473AbYBMKwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 05:52:32 -0500
Content-Disposition: inline
In-Reply-To: <20080212.181742.150703641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Feb 2008, David Miller wrote:

> From: maximilian attems <max@stro.at>
> Date: Tue, 12 Feb 2008 11:30:47 +0100
> 
> > irda_init()
> > dmesg line is not really informative, thus remove it.
> > There are better ways to know that a module is loaded.
> > 
> > Seen on a debian config with IRDA_DEBUG enabled.
> > 
> > Signed-off-by: maximilian attems <max@stro.at>
> 
> Well if you look at how IRDA_DEBUG is predominantly used,
> it's a function tracer, and that's exactly how it's being
> used here.
> 
> Either we decide that this is OK and leave it there, or
> we start moving the whole IRDA tree over to not do this.
> Not something in between.

ack, happy with both.
i could also lower the visibility of that one.

it simply struck out on my sfuzz test runs, had this
dmesg line instead of usual stuff:
-- snipp
NET: Registered protocol family 9
X.25 for Linux Version 0.2
Bridge firewalling registered
PPP generic driver version 2.4.2
NET: Registered protocol family 24
Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
NET: Registered protocol family 4
NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
DECnet: Routing cache hash table of 1024 buckets, 16Kbytes
NET: Registered protocol family 12
Bluetooth: Core ver 2.11
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
NET: Registered protocol family 15
NET: Registered protocol family 5
irda_init()
NET: Registered protocol family 23
--
