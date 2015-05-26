From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 26 May 2015 12:47:34 -0600
Message-ID: <20150526184734.GE11800@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
 <20150526165928.GC11800@obsidianresearch.com>
 <1432662396.28905.157.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1432662396.28905.157.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 01:46:36PM -0400, Doug Ledford wrote:

> > Remember, this isn't RDMA namespaces, this is netdev namespace support
> > for RDMA-CM -> very different things.
> 
> That was the point of my email.  This is a very myopic view of the
> feature.  It *should* at least have an idea of these other things too.

Everything you talked about seems covered: iwarp/roce/ib now have a
fairly clear uniform story for CM. usNIC doesn't use core code.

I doubt a larger discussion about a 'rdma namespace' is going to
substantially change these patches, they are really netdev focused.
Anyhow, I've been saving that discussion for when the roce and
umad/uverbs namespace stuff is re-sent. It seems more appropriate at
that point.

I don't know about you, but I am exhausted looking at these huge patch
sets, and narrowing the focus is the only way I see to get through.
This series has hopefully narrowed to: 'fix the flow in netdev
handling for rdma-cm'.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
