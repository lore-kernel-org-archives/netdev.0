From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 6 Jun 2017 15:44:53 -0700
Message-ID: <20170606224451.76732gjmf6vaetxx@ast-mbp>
References: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
 <20170606.143824.717466091308335341.davem@davemloft.net>
 <20170606185532.2byjdonwsyan2asl@ast-mbp.dhcp.thefacebook.com>
 <20170606.150151.1650636686526694540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org, ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jsorensen-b10kYP2dOMg@public.gmane.org, andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170606.150151.1650636686526694540.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2017 at 03:01:51PM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 6 Jun 2017 11:55:33 -0700
> 
> > If in the future mlx will make it into the nic in a way that
> > encryption shares all memory management logic and there is no fpga
> > at all then it indeed will be similar to tc offload. Right now it's
> > not and needs different sw architecture.
> 
> If the visible effect is identical, I fundamentally disagree with you.
> 
> I don't care if there is a frog sitting on the PHY that transforms
> the packets, it's all the same if the visible behavior is identical.

that frog is a good example why we disagree.
I need to check the pulse of that frog and last time it ate.
In production I cannot have magical creatures do stuff for me.
I need to monitor all components, debug and mitigate the issues.
If encryption is done by the nic, I get all the monitoring and
debugging as part of the standard tools. When it's a frog
hidden by the nic, I cannot do much when the fire erupts,
hence frog and production environment don't mix.
To move things forward...
how about marking the whole thing CONFIG_EXPERIMENTAL instead of revert?
Right now it's effectively non-production==experimental code and
I want to make it clear.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
