From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: option: oops on unload (2.6.27.4)
Date: Fri, 28 Nov 2008 17:02:04 -0800
Message-ID: <20081129010204.GA27613@kroah.com>
References: <20081128213254.GB6750@joi> <20081128215021.GA25391@suse.de> <20081128220142.GC6750@joi> <20081128235010.GB27130@suse.de> <20081128165120.4d587db0@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081128165120.4d587db0-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 28, 2008 at 04:51:20PM -0800, Arjan van de Ven wrote:
> On Fri, 28 Nov 2008 15:50:10 -0800
> Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> > > > > i2c_core sr_mod evdev dcdbas cdrom [last unloaded: uhci_hcd]
> 
> ... last unloaded was uhci_hcd ;)

Ah, good point, option wasn't unloaded first.  Yeah, this is a known
issue.  Try unloading option first.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
