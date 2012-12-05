From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [Patch 1/1] net/phy: Add interrupt support for dp83640 phy.
Date: Wed, 5 Dec 2012 11:05:44 +0100
Message-ID: <20121205100544.GA2293@netboy.at.omicron.at>
References: <1354652498-16573-1-git-send-email-stephan.gatzka@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephan Gatzka <stephan.gatzka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45614 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2LEKF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 05:05:57 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so2787672eek.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 02:05:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354652498-16573-1-git-send-email-stephan.gatzka@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 09:21:38PM +0100, Stephan Gatzka wrote:
> Added functions for ack_interrupt and config_intr. Tested on an mpc5200b
> powerpc board.
> 
> Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>

The patch looks okay to me, but I worry that this might fail on boards
which have not connected the phyer's PWERDOWN/INTN pin to anything.
Such designs really need the PHY_POLL working.

Taking a brief glance at the drivers for two such boards I know of
(m5234bcc and an IXP), it looks like their MAC drivers set mii_bus irq
to PHY_POLL, so it might work fine, but this patch still makes me
nervous that some other board might break.

Maybe this should be a kconfig option?

Thanks,
Richard
