From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: add Qualcomm IPC router
Date: Tue, 15 Dec 2015 15:13:25 -0600
Message-ID: <1450214005.4464.9.camel@redhat.com>
References: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
	 <20151215.160114.1178824607335349574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, courtney.cavin-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151215.160114.1178824607335349574.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-15 at 16:01 -0500, David Miller wrote:
> From: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
> Date: Fri, 11 Dec 2015 12:41:59 -0800
> 
> > +static unsigned int qrtr_local_nid = 1;
> > +module_param_named(node_id, qrtr_local_nid, uint, S_IRUGO);
> > +MODULE_PARM_DESC(idVendor, "Local Node Identifier");

Also s/idVendor/node_id?

Dan

> Module parameters suck.
> 
> Allow the user to choose this dynamically.  You have roughtly two
> choices.
> 
> 1) Subvert the 'protocol' field passed to ->create() and use that, it
> is
>    being ignored otherwise.
> 
> 2) Put it into the socket address for bind().
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
