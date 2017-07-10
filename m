From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 0/4] RDMAtool
Date: Mon, 10 Jul 2017 10:02:30 +0200
Message-ID: <20170710080230.GD1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170704075541.12544-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tue, Jul 04, 2017 at 09:55:37AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
>Hi,
>
>This is third version of series implementing the RDAMtool -  the tool
>to configure RDMA devices. The initial proposal was sent as RFC [1] and
>was based on sysfs entries as POC.
>
>The current series was rewritten completely to work with RDMA netlinks as
>a source of user<->kernel communications. In order to achieve that, the
>RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].
>
>The following is an example of various runs on my machine with 5 devices
>(4 in IB mode and one in Ethernet mode)
>
>### Without parameters
>$ rdma
>Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
>where  OBJECT := { dev | link | help }
>       OPTIONS := { -V[ersion] | -d[etails]}

What about json output? You will need it sooner than later. It will
prevent you from a lot of headaches if you implement it right away.
Lesson learned...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
