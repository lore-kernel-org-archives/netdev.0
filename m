From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH] usbnet: cleanup after bind() in probe()
Date: Mon, 07 Mar 2016 18:36:46 +0100
Message-ID: <1457372206.3404.12.camel@suse.com>
References: <1457346670-24059-1-git-send-email-oneukum@suse.com>
	 <20160307.114125.198056880799710267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160307.114125.198056880799710267.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-03-07 at 11:41 -0500, David Miller wrote:
> From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
> Date: Mon,  7 Mar 2016 11:31:10 +0100
> 
> > In case bind() works, but a later error forces bailing
> > in probe() in error cases work and a timer may be scheduled.
> > They must be killed. This fixes an error case related to
> > the double free reported in
> > http://www.spinics.net/lists/netdev/msg367669.html
> > and needs to go on top of Linus' fix to cdc-ncm.
> > 
> > Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
> 
> Applied, thanks Oliver.
> 
> How far back does this bug exist?  I'm trying to figure out what
> -stable branchs to send it to.

It goes back to 3.12

	HTH
		Oliver



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
