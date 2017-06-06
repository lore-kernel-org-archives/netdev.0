From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 6 Jun 2017 11:55:33 -0700
Message-ID: <20170606185532.2byjdonwsyan2asl@ast-mbp.dhcp.thefacebook.com>
References: <20170606174233.w377ctwtapzccsk7@ast-mbp.dhcp.thefacebook.com>
 <20170606.134726.416045938000214127.davem@davemloft.net>
 <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
 <20170606.143824.717466091308335341.davem@davemloft.net>
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
In-Reply-To: <20170606.143824.717466091308335341.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2017 at 02:38:24PM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 6 Jun 2017 11:34:59 -0700
> 
> > fpga is a separate device with its own phy and mac layers, its
> > own queues, packet parsing and rdma logic.
> 
> Because that's how they bolted it onto the ASIC in current
> implementation, it might not always be that way and be fully
> integrated in the future.
> 
> And I stress the word "implementation" as in "implementation detail"
> the visible behavior is going to be the same, the difference is how
> the thing is hooked up and maybe how you program it.

whether fpga is a separate chip or part of the same asic makes no difference.
They are still different devices from sw point of view.
If in the future mlx will make it into the nic in a way that encryption shares
all memory management logic and there is no fpga at all then it indeed will
be similar to tc offload. Right now it's not and needs different sw architecture.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
