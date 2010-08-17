From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet_cs: Use pr_fmt and pr_<level>
Date: Tue, 17 Aug 2010 02:34:50 -0700 (PDT)
Message-ID: <20100817.023450.71093930.davem@davemloft.net>
References: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
	<1281279036.28761.29.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w.sang@pengutronix.de, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux@dominikbrodowski.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932255Ab0HQJec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:32 -0400
In-Reply-To: <1281279036.28761.29.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 08 Aug 2010 07:50:36 -0700

> It looks as if the printks in get_ax88190 are
> incorrect and were duplicated and superceded by a
> test in pcnet_config, so I removed them.
> 
> Changed the level of the ax88190 test to KERN_NOTICE
> to match the other message styles in pcnet_config.
> 
> Compiled but untested.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
