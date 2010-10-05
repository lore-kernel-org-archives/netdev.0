From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Wed, 6 Oct 2010 07:02:42 +0900
Message-ID: <20101006070242.3ca5a6d9@s6510>
References: <1286261640-5121-1-git-send-email-bmt@zurich.ibm.com>
	<AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Oct 2010 12:57:21 +0200
Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org> wrote:

> > + * TODO: Dynamic device management (network device registration/removal).  
> 
> The current implementation is such that one siw device is created for
> each network device found at kernel module load time. That means that
> you force the user to load the siw kernel module after all other
> kernel modules that register a network device. I'm not sure that's a
> good idea.

Then device should be controlled by a netlink (rtnl_link_ops) style
interface see vlan_netlink.c. Using netlink is extensible and provides
a cleaner interface than all these other parameterization methods.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
