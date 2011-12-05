From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization
 flow to accommodate SRIOV for Ethernet
Date: Mon, 5 Dec 2011 09:40:55 +0200
Message-ID: <4EDC7587.9020909@mellanox.com>
References: <4ED8A636.40901@mellanox.co.il> <201112041629.41466.jackm@dev.mellanox.co.il> <4EDB942F.1020101@mellanox.com> <201112050919.39280.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201112050919.39280.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/5/2011 9:19 AM, Jack Morgenstein wrote:
> If CONFIG_PCI_IOV isn't set, pci_enable_sriov isn't there...

> Not so.  I checked. If CONFIG_PCI_IOV isn't set, pci_enable_sriov returns -ENODEV via a static inline function. Look in kernel file include/linux/pci.h (for the most recent kernel)

Sure, sorry, my bad, thanks for clarifying this out.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
