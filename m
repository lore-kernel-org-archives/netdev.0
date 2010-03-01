From: Or Gerlitz <ogerlitz-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use	netdev_for_each_mc_addr
Date: Mon, 01 Mar 2010 09:48:09 +0200
Message-ID: <4B8B7139.9050707@Voltaire.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>	<4B862E07.7020002@Voltaire.com>	<20100225084915.GA3171@psychotron.redhat.com>	<20100227060146.GA13231@obsidianresearch.com>	<20100227103835.GA2862@psychotron.redhat.com> <20100227184410.GB13231@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Moni Shoua <monis-hKgKHo2Ms0F+cjeuK/JdrQ@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100227184410.GB13231-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jason Gunthorpe wrote:
> Jiri Pirko wrote:
>> when bonding changes it's type, flush mc addresses and start over.

> There was a patch posted that tried to do something like what you are describing

Indeed, Jason, commit 75c785 "bonding: remap muticast addresses without using dev_close() and dev_open()" from Moni Shoua <monis-smomgflXvOZWk0Htik3J/w@public.gmane.org> does exactly that, isn't it?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
