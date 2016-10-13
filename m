From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment
 workaround
Date: Thu, 13 Oct 2016 09:50:12 -0400 (EDT)
Message-ID: <20161013.095012.244532868281403236.davem@davemloft.net>
References: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: robert.jarzmik-GANU6spQydw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476045227-2970-1-git-send-email-robert.jarzmik-GANU6spQydw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Date: Sun,  9 Oct 2016 22:33:45 +0200

> Writes to u16 has a special handling on 3 PXA platforms, where the
> hardware wiring forces these writes to be u32 aligned.
> 
> This patch isolates this handling for PXA platforms as before, but
> enables this "workaround" to be set up dynamically, which will be the
> case in device-tree build types.
> 
> This patch was tested on 2 PXA platforms : mainstone, which relies on
> the workaround, and lubbock, which doesn't.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>

Please resubmit this patch series:

1) Respun against net-next, these don't currently apply cleanly there.

2) With a proper "[PATCH 0/3] ..." posting explaining at a high level
   what this patch series does, how it does it, and why it does it
   that way.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
