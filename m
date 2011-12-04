From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization
 flow to accommodate SRIOV for Ethernet
Date: Sun, 4 Dec 2011 17:39:27 +0200
Message-ID: <4EDB942F.1020101@mellanox.com>
References: <4ED8A636.40901@mellanox.co.il> <CAL1RGDV8LzSOei=aQW7VXUP=G+9qdO+Y4eKZu8mBuHJuUp8UuQ@mail.gmail.com> <201112041629.41466.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201112041629.41466.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/4/2011 4:29 PM, Jack Morgenstein wrote:
> If the kernel is not configured to support IOV, pci_enable_sriov will 
> fail.
Jack,

If CONFIG_PCI_IOV isn't set, pci_enable_sriov isn't there...

Or.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
