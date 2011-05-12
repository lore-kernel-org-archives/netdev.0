From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Thu, 12 May 2011 13:46:55 -0400 (EDT)
Message-ID: <20110512.134655.235895548164532973.davem@davemloft.net>
References: <201105111937.47448.oliver@neukum.org>
	<20110511.134727.957370621658043260.davem@davemloft.net>
	<201105120959.28473.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105120959.28473.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Thu, 12 May 2011 09:59:28 +0200

> Our problem here is that USB doesn't work sanely without
> interrupts. We can stop IO regarding rx, but we cannot stop
> interrupts if we want to do rx.

Understood.

However, I was wondering if you could do this in software.  When URBs
trigger, just queue that pending work up in a software queue when NAPI
is scheduled, then when you exit NAPI polling you check that queue to
see if there are interrupt events to process.

Similarly to how we handle software interrupts.

Anyways, just an idea.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
