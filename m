From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [net-next 02/10] ioc3-eth/meth: Move the SGI drivers
Date: Thu, 18 Aug 2011 20:46:31 +0100
Message-ID: <20110818194631.GE22920@linux-mips.org>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1313134384-7287-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:39740 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751951Ab1HRTqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 15:46:40 -0400
Content-Disposition: inline
In-Reply-To: <1313134384-7287-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2011 at 12:32:56AM -0700, Jeff Kirsher wrote:

> diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
> new file mode 100644
> index 0000000..3098594
> --- /dev/null
> +++ b/drivers/net/ethernet/sgi/Kconfig
> @@ -0,0 +1,34 @@
> +#
> +# SGI device configuration
> +#
> +
> +config NET_VENDOR_SGI
> +	bool "SGI devices"
> +	depends on (PCI && SGI_IP27) || SGI_IP32

Can you make NET_VENDOR_SGI default to y for these systems?  There is
normally no reason other than maybe testing to ever disable NET_VENDOR_SGI
as these NICs are all on the motherboard.

Otherwise ok.  Thanks,

  Ralf
