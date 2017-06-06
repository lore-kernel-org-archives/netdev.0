From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 06 Jun 2017 15:01:51 -0400 (EDT)
Message-ID: <20170606.150151.1650636686526694540.davem@davemloft.net>
References: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
        <20170606.143824.717466091308335341.davem@davemloft.net>
        <20170606185532.2byjdonwsyan2asl@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org, ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jsorensen-b10kYP2dOMg@public.gmane.org, andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170606185532.2byjdonwsyan2asl-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 6 Jun 2017 11:55:33 -0700

> If in the future mlx will make it into the nic in a way that
> encryption shares all memory management logic and there is no fpga
> at all then it indeed will be similar to tc offload. Right now it's
> not and needs different sw architecture.

If the visible effect is identical, I fundamentally disagree with you.

I don't care if there is a frog sitting on the PHY that transforms
the packets, it's all the same if the visible behavior is identical.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
