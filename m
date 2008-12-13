From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/33] sfc: Change SPI lengths to type size_t
Date: Sat, 13 Dec 2008 06:30:11 +0000
Message-ID: <20081213063010.GJ10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com> <20081212124622.GK32518@solarflare.com> <20081212124851.GB10372@solarflare.com> <20081212.215324.196962741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:48405 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755996AbYLMGaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:30:14 -0500
Content-Disposition: inline
In-Reply-To: <20081212.215324.196962741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 12 Dec 2008 12:48:51 +0000
> 
> > Based on a patch by Andrew Morton.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Sigh, this isn't what you actually build tested, that's
> for sure:

Of course it is.  But it looks like I forgot to test the final version
of this patch on a 64-bit architecture.  On i386 size_t = unsigned.

> drivers/net/sfc/falcon.c:1664: error: conflicting types for 'falcon_spi_cmd'
> drivers/net/sfc/spi.h:71: error: previous declaration of 'falcon_spi_cmd' was here
> 
> I'll fix it up this time, but never will I do this again.
 
Thanks.

Ben.

> Test what you send me.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
