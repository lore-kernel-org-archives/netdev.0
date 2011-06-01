From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] Add Fujitsu 1000base-SX PCI ID to tg3
Date: Wed, 1 Jun 2011 14:14:01 -0700
Message-ID: <20110601211401.GB1482@mcarlson.broadcom.com>
References: <alpine.SOC.1.00.1105251836550.16961@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Meelis Roos" <mroos@ut.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1944 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab1FAVKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 17:10:14 -0400
In-Reply-To: <alpine.SOC.1.00.1105251836550.16961@math.ut.ee>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 08:43:47AM -0700, Meelis Roos wrote:
> This patch adds the PCI ID of Fujitsu 1000base-SX NIC to tg3 driver. 
> Tested to detect the card, MAC and serdes, not tested with link at the 
> moment since I have no fiber switch here. I did not add new constants to 
> the pci_ids.h header file since these constants are used only here.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 7a5daef..7b1901e 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -273,6 +273,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
>  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1003)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC9100)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_TIGON3)},
> +	{PCI_DEVICE(0x10cf, 0x11a2)}, /* Fujitsu 1000base-SX with BCM5703SKHB */
>  	{}
>  };

I don't have any problems with the patch, but before we integrate it,
can we make sure it passes traffic?  I'd hate to add support for a
device and later find out it doesn't work.

