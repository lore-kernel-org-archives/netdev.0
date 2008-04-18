From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [patch 3/3] hci_usb.h: fix hard-to-trigger race
Date: Fri, 18 Apr 2008 14:21:53 -0700
Message-ID: <20080418142153.4e0eb83b.akpm@linux-foundation.org>
References: <200804182046.m3IKksxT014631@imap1.linux-foundation.org>
	<55DEC459-2D49-4366-88CC-21E9CA6783DC@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, pavel-AlSwsSmVLrQ@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55DEC459-2D49-4366-88CC-21E9CA6783DC-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Apr 2008 23:10:12 +0200
Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wrote:

> Hi Andrew,
> 
> > From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
> >
> > If someone tries to _urb_unlink while _urb_queue_head is running,  
> > he'll see
> > _urb->queue == NULL and fail to do any locking.  Prevent that from  
> > happening
> > by strategically placed barriers.
> 
> let me repeat this, the hci_usb driver is not worth fixing. Doing our  
> own URB handling is a bad idea. The btusb driver should fix all of  
> this. Only exception is that it is missing all the quirks, but that  
> was me being lazy.
> 

ok...  But as long as the old code is buildable and installable, we should
fix bugs in it?
