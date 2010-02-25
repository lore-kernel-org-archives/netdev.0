From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/7] pci: Add PCI LRDT tag size and section size
Date: Thu, 25 Feb 2010 10:53:45 -0800
Message-ID: <20100225105345.0baadeb4@nehalam>
References: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Feb 2010 10:19:16 -0800
"Matt Carlson" <mcarlson@broadcom.com> wrote:

> +++ b/include/linux/pci-vpd.h
> @@ -0,0 +1,26 @@
> +/*
> + *	pci-vpd.h
> + *
> + *	PCI VPD defines and function prototypes
> + *
> + *	Copyright (C) 2010 Broadcom Corporation.
> + *
> + *	For more information, please consult the following manuals (look at
> + *	http://www.pcisig.com/ for how to get them):
> + *
> + *	PCI Local Bus Specification, Rev. 3.0 : Appendix I
> + */
> +
> +#ifndef LINUX_PCI_VPD_H
> +#define LINUX_PCI_VPD_H
> +
> +#include <linux/pci.h>
> +
> +#define PCI_VPD_LRDT_TAG_SIZE	3
> +
> +static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
> +{
> +	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
> +}
> +
> +#endif /* LINUX_PCI_VPD_H */
> -- 

No need for new file for this, it should be part of existing pci.h
Also need kernel doc format comment to describe usage.
Shouldn't the function take the pci resource not just the register.

And finally, how common is this or is it just something unique to your hw.
