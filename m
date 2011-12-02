From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH net-next V0 18/21] mlx4_core: adjust catas operation for
 SRIOV mode
Date: Fri, 2 Dec 2011 09:07:09 -0800
Message-ID: <CAL1RGDWp2fysTgVgSi30X+nf=66fArPRdXUXedbKxKjyHQqidQ@mail.gmail.com>
References: <4ED8A62D.8080008@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED8A62D.8080008-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 2, 2011 at 2:19 AM, Yevgeny Petrilin
<yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> wrote:
> When running in SRIOV mode, driver should not automatically start/stop
> the mlx4_core upon sensing an HCA internal error -- doing this disables/enables
> sriov, which will cause the hypervisor to hang if there are running VMs with
> attached VFs.

Not sure I understand this -- what happens if the driver doesn't reset
the device
after a catastrophic error?  Surely all the VFs are pretty screwed at
that point?

Which hypervisor are we talking about here anyway?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
