From: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP
 exception table
Date: Wed, 28 Aug 2013 23:51:49 -0600
Message-ID: <20130828235149.47bc9db9ac701167d0d03998@gmail.com>
References: <20130828171812.7097dc8334046b464486d4a3@gmail.com>
	<20130828.200111.1548126886406334118.davem@davemloft.net>
	<20130828184022.9a5b54e8df63aaf8c82bf9b5@gmail.com>
	<20130829.003352.1187611479213752660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130829.003352.1187611479213752660.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Aug 2013 00:33:52 -0400 (EDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 28 Aug 2013 18:40:22 -0600
> 
> > The exception list means "usb_device_id entries for specific devices
> > that are known to need the workaround." There are just two such entries.
> > There isn't even a separate list. So maybe we just have a nomenclature
> > problem, and we could simply be calling this a "white list" instead of
> > "exception list". The other possible meaning of whitelist (all devices
> > that *don't* need the workaround) is unthinkable, as that would be a huge
> > list and much more prone to be unmanageable than what we've got now.
> 
> Ok I misunderstood.  I thought we were discoving that all chips which
> have been thoroughly investigated end up needing the workaround.
> 
> I guess it's only a specific family of these chips which seem to all
> have the problem?

Yes. The first one was the Sierra MC7710, and the second is the one
that I discovered, the HP hs2434, which is actually manufactured by
Sierra. So it may be an issue specific to Sierra, but unfortunately the
hs2434 uses HP's manufacturer id (0x3f0) and not Sierra's manufacturer
id (0x1199) so we can't just discriminate based on that.

-- 
Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
