From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA aligned and are about to be DMA mapped
Date: Sun, 16 Jun 2013 10:21:29 +0200
Message-ID: <6777683.xBFsv58ruI@linux-5eaq.site>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <51BC67D7.90006@iki.fi> <51BC6A96.7030707@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51BC6A96.7030707-X3B1VOXEql0@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 15 June 2013 16:22:30 Jussi Kivilinna wrote:

> Hm.. rethink this a bit.
> 
> Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
> used as something else. Manual alignment by host driver does not catch that
> or fix that.
> So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
> problem is multiple buffers from same cacheline.

The buffers kmalloc() returns are OK in that regard. A driver that uses
a buffer for anything but buffering is buggy.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
