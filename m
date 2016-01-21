From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 12:24:20 -0600
Message-ID: <20160121182420.GA51708@flatif-MOBL1>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
 <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
 <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
 <56A08E8F.7090602@mellanox.com>
 <004401d15460$e77fa1b0$b67ee510$@opengridcomputing.com>
 <56A10FEC.5020402@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	'Or Gerlitz' <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	'Linux Netdev List' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'Jeff Kirsher' <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56A10FEC.5020402-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 21, 2016 at 07:05:48PM +0200, Or Gerlitz wrote:
> On 1/21/2016 5:32 PM, Steve Wise wrote:
> >Only a single user-space daemon is used.
> 
> Good.
> 
> >Someone from Intel might have insight into the architecture and design.  Perhaps the intention is that individual drivers might want to have their own handlers for these various operations.  But currently they all use the core/common ones.
> 
> But if there's single daemon there and one set of pre-defined  callbacks,
> why different netlink commands are needed? in what case the damon uses
> RDMA_NL_NES or RDMA_NL_C4IW or the new define and why?
> 
> Or.

The Intel X722 iWARP driver implements the port mapper interface as is in the current kernel, utilizing iwpm.

The portmapper daemon sends netlink messages to the client drivers (nes, cxgb4) and RDMA_NL_NES/RDMA_NL_C4IW
enums are part of the netlink message header used by the netlink protocol to deliver the messages to the
corresponding client.

We can certainly take up the discussion on improving the current port mapper design/implementation. But
that would be more appropriate in a separate thread.

Thanks
Faisal
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
