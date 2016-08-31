From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 3/8] thunderbolt: Kconfig for Thunderbolt(TM)
 networking
Date: Wed, 31 Aug 2016 13:30:10 +0200
Message-ID: <20160831113010.GD17607@kroah.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
 <1470054233-4309-4-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:33657 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754570AbcHaLaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 07:30:11 -0400
Content-Disposition: inline
In-Reply-To: <1470054233-4309-4-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 01, 2016 at 03:23:48PM +0300, Amir Levy wrote:
> Updating the Kconfig Thunderbolt(TM) description.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/Kconfig  | 25 +++++++++++++++++++++----
>  drivers/thunderbolt/Makefile |  2 +-
>  2 files changed, 22 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/thunderbolt/Kconfig b/drivers/thunderbolt/Kconfig
> index c121acc..d34b0f5 100644
> --- a/drivers/thunderbolt/Kconfig
> +++ b/drivers/thunderbolt/Kconfig
> @@ -1,13 +1,30 @@
> -menuconfig THUNDERBOLT
> -	tristate "Thunderbolt support for Apple devices"
> +config THUNDERBOLT
> +	tristate "Thunderbolt(TM) support"
>  	depends on PCI
>  	select CRC32
>  	help
> -	  Cactus Ridge Thunderbolt Controller driver
> +	  Thunderbolt(TM) Controller driver
> +
> +if THUNDERBOLT
> +
> +config THUNDERBOLT_APPLE
> +	tristate "Apple hardware support"

Wait, what?  What about my non-apple thunderbolt hardware?  Did that
just suddenly stop working?  Why rename this option?

greg k-h
