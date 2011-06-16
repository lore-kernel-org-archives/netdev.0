From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Thu, 16 Jun 2011 13:51:01 +0200
Message-ID: <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 06/15/2011 08:57:38 PM:

> On Wed, Jun 15, 2011 at 5:43 PM, Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
wrote:
> > after rebasing to davem/net-next-2.6.git, I formatted a patch adding
> > to the initial 'siw' driver posting from last October. Given the rather
> > substantial amount of changes and time elapsed, I am not sure if people
> > would better like a complete re-posting of all files.
> > If I don't hear objection before tomorrow I would post it as an
> > increment - as summarized below.
>
> Documentation in general and for sysfs attributes in particular seems
> to be missing ?
>
> Also, the following statement in siw_main.c:
>
> ibdev->modify_port = NULL;

oh, thanks...!

I was expecting there is an ib_device->uverbs_cmd_mask
flag which siw does not set... Unfortunately, it is not
completely clear to me when a command mask bit is available
and when the OFA core strictly expects a function pointer.
Maybe there is some redundancy/inconsistency?


Thanks,
Bernard.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
