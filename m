From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization
 flow to accommodate SRIOV for Ethernet
Date: Mon, 5 Dec 2011 11:01:42 -0800
Message-ID: <CAL1RGDWsenbb6Z6pZtQ056itHgom08WryLJ-6=+okSh1xbgP=A@mail.gmail.com>
References: <4ED8A636.40901@mellanox.co.il> <CAL1RGDV8LzSOei=aQW7VXUP=G+9qdO+Y4eKZu8mBuHJuUp8UuQ@mail.gmail.com>
 <201112041629.41466.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201112041629.41466.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 4, 2011 at 6:29 AM, Jack Morgenstein
<jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> If the kernel is not configured to support IOV, pci_enable_sriov will=
 fail.
> Currently, we abort the device startup. =A0I can change this to simpl=
y continue
> without sriov enabled:

Agree... we definitely don't want drivers failing just because a
device has an SR-IOV
cap but the kernel isn't compiled with SR-IOV support.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
