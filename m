From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use
	netdev_for_each_mc_addr
Date: Tue, 2 Mar 2010 13:01:15 +0100
Message-ID: <20100302120114.GD2669@psychotron.redhat.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
 <4B862E07.7020002@Voltaire.com>
 <20100225084915.GA3171@psychotron.redhat.com>
 <20100227060146.GA13231@obsidianresearch.com>
 <20100227103835.GA2862@psychotron.redhat.com>
 <20100227184410.GB13231@obsidianresearch.com>
 <4B8B7139.9050707@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Moni Shoua <monis-smomgflXvOZWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B8B7139.9050707-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mon, Mar 01, 2010 at 08:48:09AM CET, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org wrote:
>Jason Gunthorpe wrote:
>> Jiri Pirko wrote:
>>> when bonding changes it's type, flush mc addresses and start over.
>
>> There was a patch posted that tried to do something like what you are describing
>
>Indeed, Jason, commit 75c785 "bonding: remap muticast addresses without using dev_close() and dev_open()" from Moni Shoua <monis-smomgflXvOZWk0Htik3J/w@public.gmane.org> does exactly that, isn't it?

This affects different mc_list.

>
>Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
