From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Sun, 5 Jun 2011 19:39:17 +0200
Message-ID: <OF7015801A.F56F7EB3-ONC12578A6.0059A93C-C12578A6.0060FB03@ch.ibm.com>
References: <OF64770AFC.B48EBEF2-ONC12577A6.002CC793-C12577A6.002DC569@ch.ibm.com> <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bart,
many thanks for polling. About nine months ago we sent an initial
'softiwarp' patch to netdev and linux-rdma. We got encouraging
feedback including very helpful advice on how to improve that code.
I think we fixed all issues which were detected by the community
but somehow missed the point to feed back the code. Sorry about that.
Due to pressure from other projects softiwarp went a little
down on my priority list. But its immediately back when you are asking ;)

What we currently have is a stack which - due to requirements
from other projects - evolved further to now include also 
some kernel client support (tested with NFSv4). We also fixed
issues in the connection management code path, which improved
stability. We also added some siw object statistics for debugging.

As mentioned, while keeping gitorious.org/softiwarp up to date
(it includes the latest changes) we missed to come back to the
list. I will now resume working on that, dedicating some more
of my time to it. Let me rebase the code with the current kernel
and send a new patch list later next week. 

Many thanks, and sorry for the long-lasting silence,
Bernard.

linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 06/04/2011 08:01:45 PM:

> Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org> 
> Sent by: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> 06/04/2011 08:02 PM
> 
> To
> 
> Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
> 
> cc
> 
> linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Subject
> 
> Re: software iwarp stack update
> 
> On Wed, Sep 22, 2010 at 10:19 AM, Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> 
wrote:
> > Earlier this year, we announced the availability of an open source,
> > full software implementation of the iWARP RDMA protocol stack - see
> > my email "software iwarp stack" from March 14th at the linux-rdma list
> > (http://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg02940.html)
> > While since then working on performance and stability, we provided
> > some source code updates. Current user and kernel code is available at
> > gitorious.org/softiwarp. Please see the CHANGES file in the
> > kernel/ directory for a summary of the most recent changes.
> 
> (replying to an e-mail of about nine months ago)
> 
> Hello Bernard,
> 
> It has been pretty quiet recently around the "siw" driver. Have you
> had the chance to make any progress recently on this driver ?
> 
> Thanks,
> 
> Bart.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
