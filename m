From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Wed, 6 Oct 2010 16:11:55 +0200
Message-ID: <OFA817AEA2.469903E5-ONC12577B4.004DBC8C-C12577B4.004DFF18@ch.ibm.com>
References: <20101006070242.3ca5a6d9@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101006070242.3ca5a6d9@s6510>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote on 10/06/2010 12:02:42 AM:

> On Tue, 5 Oct 2010 12:57:21 +0200
> Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org> wrote:
>
> > > + * TODO: Dynamic device management (network device
> registration/removal).
> >
> > The current implementation is such that one siw device is created for
> > each network device found at kernel module load time. That means that
> > you force the user to load the siw kernel module after all other
> > kernel modules that register a network device. I'm not sure that's a
> > good idea.
>
> Then device should be controlled by a netlink (rtnl_link_ops) style
> interface see vlan_netlink.c. Using netlink is extensible and provides
> a cleaner interface than all these other parameterization methods.

makes sense to me. Bart?

thanks,
bernard.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
