From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 16821] New: g_ether no carrier while it is
Date: Tue, 24 Aug 2010 16:40:06 -0700
Message-ID: <20100824164006.0bd7b7e8.akpm@linux-foundation.org>
References: <bug-16821-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>, public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bug-16821-10286-3bo0kxnWaOQUvHkbgXJLS5sdmw4N0Rt+2LY78lusg7I@public.gmane.org/>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 23 Aug 2010 06:24:16 GMT
bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16821
> 
>            Summary: g_ether no carrier while it is
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.3(2 - ok, 3?, 4-6 - fail)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org
>         ReportedBy: public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
>         Regression: Yes
> 
> 
> After successfully loaded g_ether module (with use_eem=0) usb device appears.
> If I configure it at host as ifconfig usb0 blah bah, than network present, all
> ok. 
> In windows (with RNDIS config), and in linux with bridge it looks to CARRIER
> state. I get in ip addr state DOWN, NO-CARRIER. That's why g_ether usb device
> in bridge and windows don't work at all.

So g_ether broke after 2.6.32?

Nobody really seems to do much with that USB driver.  I wonder if some
changes in core networking could have triggered this?

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
