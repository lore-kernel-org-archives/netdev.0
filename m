From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14711] New: usbnet ax88172 mac address change
 broken
Date: Thu, 3 Dec 2009 13:38:45 -0800
Message-ID: <20091203133845.4977551c.akpm@linux-foundation.org>
References: <bug-14711-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	remur-hi6Y0CQ0nG0@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bug-14711-10286-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 1 Dec 2009 15:41:10 GMT
bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14711
> 
>            Summary: usbnet ax88172 mac address change broken
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.31rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>         ReportedBy: remur-hi6Y0CQ0nG0@public.gmane.org
>         Regression: No
> 
> 
> When changing the MAC address on a NETGEAR FA120 (because an old one is
> registered with my provider) the replies to the traffic don't reach the system
> anymore, the NIC is dropping them, putting the NIC into promiscous mode will
> show they are properly replied to.
> 
> Searching around I found this patch from the openBSD folks
> http://www.mail-archive.com/misc-7YlrpqBBQ3VAfugRpC6u6w@public.gmane.org/msg76418.html
> http://www.openbsd.org/cgi-bin/cvsweb/src/sys/dev/usb/if_axe.c.diff?r1=1.91;r2=1.92
> 
> Looks like it is not working with the ax88172, but only with newer models.
> Still an error message would be nice when setting another physical address
> 

It would be nice if some asix-competent person could take a look at porting
that openbsd patch across, see if it fixes Karsten's hardware.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
