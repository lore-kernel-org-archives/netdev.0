From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/7] MAINTAINERS: update information for sfc network
 driver
Date: Wed, 26 Aug 2009 11:47:47 -0700
Message-ID: <1251312467.13026.22.camel@Joe-Laptop.home>
References: <1251310744.27345.21.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1395 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbZHZSrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 14:47:46 -0400
In-Reply-To: <1251310744.27345.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-26 at 19:19 +0100, Ben Hutchings wrote:
> Update the current maintainers and add our email addresses.  Robert
> Stonehouse has moved on to other projects.
> 
> Move the linux-net-drivers alias to the top since it should always
> reach the current maintainers at Solarflare.  Add netdev as the
> relevant mailing list.
[]
> +M:	linux-net-drivers@solarflare.com (alias for current maintainers)

Hi Ben

This form: "M:	bare address (extra stuff)" doesn't work
with the get_maintainers script.

Can you please use something like this instead?

M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>

Perhaps this diff below.

diff --git a/MAINTAINERS b/MAINTAINERS
index 866253d..058ada4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4521,9 +4521,10 @@ S:	Supported
 F:	drivers/net/benet/
 
 SFC NETWORK DRIVER
-P:	Steve Hodgson
-P:	Ben Hutchings
-M:	Robert Stonehouse <linux-net-drivers@solarflare.com>
+M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
+M:	Steve Hodgson <shodgson@solarflare.com>
+M:	Ben Hutchings <bhutchings@solarflare.com>
+L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/sfc/
 


