From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Tue, 06 Jun 2017 13:47:26 -0400 (EDT)
Message-ID: <20170606.134726.416045938000214127.davem@davemloft.net>
References: <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
        <20170606161709.GA8671@obsidianresearch.com>
        <20170606174233.w377ctwtapzccsk7@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org, ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jsorensen-b10kYP2dOMg@public.gmane.org, andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org,
        yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170606174233.w377ctwtapzccsk7-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 6 Jun 2017 10:42:35 -0700

> so it's like rdma, but without using kernel rdma stack?

No sockets here, just transformation rules.  It's like offloading
a complex TC rule to hardware version of that transformation.

Yes, there is state, but I argue that it is no different than TC
offloading rules.  What if TC had "hash" and "crypt" operations
and we attached them to appropriate u32 matches?  You wouldn't
be able to tell the difference.

I think you are way over-obsessed with this FPGA offload thing,
quite frankly.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
