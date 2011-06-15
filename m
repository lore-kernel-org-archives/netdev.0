From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Wed, 15 Jun 2011 17:43:04 +0200
Message-ID: <OFC721DC15.CBE893E3-ONC12578B0.0053737C-C12578B0.00565784@ch.ibm.com>
References: <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bart, all,
after rebasing to davem/net-next-2.6.git, I formatted a patch adding
to the initial 'siw' driver posting from last October. Given the rather
substantial amount of changes and time elapsed, I am not sure if people
would better like a complete re-posting of all files.
If I don't hear objection before tomorrow I would post it as an
increment - as summarized below.

Many thanks for advice,
Bernard.

 drivers/infiniband/hw/siw/Makefile |    2 +-
 drivers/infiniband/hw/siw/iwarp.h |  100 +++++++++++++++++
+------------------
 drivers/infiniband/hw/siw/siw.h |  128 +++++++++++++++++
+--------------------
 drivers/infiniband/hw/siw/siw_main.c |  229 +++++++++++++++++++++++++++
+------
 drivers/infiniband/hw/siw/siw_ae.c    |    2 +-
 drivers/infiniband/hw/siw/siw_verbs.c |  572 ++++++++++++++++++++
+------------
 drivers/infiniband/hw/siw/siw_verbs.h |    3 +
 drivers/infiniband/hw/siw/siw_cm.c | 1158 +++++++++++++++++
+------------------
 drivers/infiniband/hw/siw/siw_cm.h |   38 +-
 drivers/infiniband/hw/siw/siw_obj.c |  165 +++++++++++++
+---------------------
 drivers/infiniband/hw/siw/siw_obj.h |   34 +++++++-
 drivers/infiniband/hw/siw/siw_qp.c |  128 ++++++++++++++++++++
+---------------
 drivers/infiniband/hw/siw/siw_cq.c |   24 ++++--------------------
 drivers/infiniband/hw/siw/siw_qp_tx.c |  147 ++++++++++++++++++
+--------------
 drivers/infiniband/hw/siw/siw_qp_rx.c |  234 ++++++++++++++++++++
+------------
 Documentation/networking/siw.txt |   62 +++++++++++++++++++++++++
+-----------
 drivers/infiniband/hw/siw/siw_mem.c |  178 +++++++++++++++++++++++++++++++
++++


linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 06/04/2011 08:01:45 PM:

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
