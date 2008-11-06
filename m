From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 6/7] drivers/net/sfc/falcon.c: fix min() warnings
Date: Thu, 06 Nov 2008 12:33:15 +0000
Message-ID: <1225974795.3150.1.camel@achroite>
References: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
	 <49128300.1000602@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	jgarzik@redhat.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:53204 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753366AbYKFMdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 07:33:19 -0500
In-Reply-To: <49128300.1000602@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-06 at 00:39 -0500, Jeff Garzik wrote:
> akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > drivers/net/sfc/falcon.c: In function 'falcon_spi_write_limit':
> > drivers/net/sfc/falcon.c:1679: warning: comparison of distinct pointer types lacks a cast
> > drivers/net/sfc/falcon.c: In function 'falcon_spi_read':
> > drivers/net/sfc/falcon.c:1720: warning: comparison of distinct pointer types lacks a cast
> > 
> > Driver seems rather confused about types.  Try to help it.
[...]
> I would prefer min_t()...

Andrew has dropped this patch as it is no longer applicable.  I do have
a patch to clean up the length types which I'll submit later.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

