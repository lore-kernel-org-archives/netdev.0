From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Mon, 5 Jun 2017 09:17:24 -0600
Message-ID: <20170605151724.GA20182@obsidianresearch.com>
References: <20170526175624.5xxflpf24je5673h@ast-mbp>
 <20170526181517.GA3860@obsidianresearch.com>
 <AM4PR0501MB1940330F0EBAA819C87C5278DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529153131.GB7924@obsidianresearch.com>
 <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529160252.GA27550@obsidianresearch.com>
 <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170601153704.GA1680@obsidianresearch.com>
 <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        "yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB19404B83A69B87AFB1326B45DBF50-dp/nxUn679gfNUYDR5dMTsDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2017 at 07:51:24AM +0000, Ilan Tayari wrote:
> > From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> > Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
> > 
> > On Mon, May 29, 2017 at 04:09:06PM +0000, Ilan Tayari wrote:
> > 
> > > > For IPSec, this is already in the kernel.
> > > > See this patchset:
> > > > http://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg162876.html
> > >
> > > Sorry, I pointed at the RFC by mistake.
> > >
> > > This is the relevant pull request:
> > > https://patchwork.ozlabs.org/patch/752707/
> > 
> > This is connecting ipsec to a netdev, while Innova seems to be a
> 
> Jason,
> 
> "network connected ipsec accelerator configured using IP packets."
> No. This is incorrect.
> Where did you get that from?

That is what you described to me - you said the only way to configure
the FPGA was via IP packets in-band. It is not part of the NIC and the
NIC only loads the FPGA bitstream.

Maybe you should explain more how this works?

> So you configure it from userspace with regular IPSec 'ip xfrm
> state' commands or over netlink with your favorite IKE daemon.

But you don't give an ip xfrm configuration to the NIC when you submit
the work request? By your description it sounded liked the FPGA
pattern matches packets from the NIC side to apply the xfrm.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
