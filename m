From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: mdio_clause45_read errors go unnoticed
Date: Fri, 27 Feb 2009 16:45:17 +0000
Message-ID: <1235753117.3164.2.camel@achroite>
References: <49A81565.3030004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:45447 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756013AbZB0Qpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:45:31 -0500
In-Reply-To: <49A81565.3030004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-02-27 at 17:31 +0100, Roel Kluin wrote:
> This patch was not tested in any way, but:
> 
> since commit 27dd2caca4eabe7c13a052b7456495ba75535e6a
> ------------------------------>8-------------8<---------------------------------
> mdio_clause45_read may return -ERR, but since 'devices' is unsigned, this is not
> noticed.

I already submitted a fix for this.  I do need to resubmit it for
net-next-2.6 though.  Thanks for the reminder.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

