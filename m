From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] pcnet_cs: Use proper netdev_*-printouts
Date: Mon, 9 Aug 2010 17:34:10 +0200
Message-ID: <20100809153410.GA27238@comet.dominikbrodowski.net>
References: <1281279036.28761.29.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	David Miller <davem@davemloft.net>
To: Wolfram Sang <w.sang@pengutronix.de>, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:34210 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754294Ab0HKRGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 13:06:09 -0400
Content-Disposition: inline
In-Reply-To: <1281279036.28761.29.camel@Joe-Laptop.home>
 <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 08, 2010 at 02:32:05PM +0200, Wolfram Sang wrote:
> To prevent broken messages like:
> 
> [  204.024291] eth%d: pcnet_reset_8390() did not complete.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Joe Perches <joe@perches.com>
> Cc: David Miller <davem@davemloft.net>

and

On Sun, Aug 08, 2010 at 07:50:36AM -0700, Joe Perches wrote:
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

look good from a PCMCIA point of view, therefore:

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

Thanks,
	Dominik
