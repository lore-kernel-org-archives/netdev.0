From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 2/3] econet: Move to staging
Date: Wed, 24 Nov 2010 10:04:27 -0800
Message-ID: <20101124180427.GA9974@suse.de>
References: <1290484348.6770.1329.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40392 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab0KXSHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:07:02 -0500
Content-Disposition: inline
In-Reply-To: <1290484348.6770.1329.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 23, 2010 at 03:52:28AM +0000, Ben Hutchings wrote:
> Recent review has revealed several bugs in obscure protocol
> implementations that can be exploited by local users for denial of
> service or privilege escalation.
> 
> The econet protocol (PF_ECONET) is unmaintained.  There appear to be
> no published applications for it, and it has never progressed beyond
> 'experimental' status.
> 
> This protocol generally should not be enabled by distributions, since
> the cost of a security flaw affecting all installed systems presumably
> outweighs the benefit to the few (if any) legitimate users.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  drivers/staging/Kconfig |    2 ++
>  net/Kconfig             |    1 -
>  2 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
> index dd94cb2..a9dd984 100644
> --- a/drivers/staging/Kconfig
> +++ b/drivers/staging/Kconfig
> @@ -177,5 +177,7 @@ source "drivers/staging/speakup/Kconfig"
>  
>  source "net/decnet/Kconfig"
>  
> +source "net/econet/Kconfig"
> +
>  endif # !STAGING_EXCLUDE_BUILD
>  endif # STAGING
> diff --git a/net/Kconfig b/net/Kconfig
> index 9e4fc29..059c9f1 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -205,7 +205,6 @@ source "net/ipx/Kconfig"
>  source "drivers/net/appletalk/Kconfig"
>  source "net/x25/Kconfig"
>  source "net/lapb/Kconfig"
> -source "net/econet/Kconfig"

No, please move the code itself to drivers/staging/ so we know to then
delete it after a few kernel versions.

thanks,

greg k-h
