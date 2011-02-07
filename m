From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 28532] New: Link state change detection
 problem on Moschip MCS7832 [mcs7830]
Date: Mon, 7 Feb 2011 15:14:01 -0800
Message-ID: <20110207151401.d1db088a.akpm@linux-foundation.org>
References: <bug-28532-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, myxal.mxl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bug-28532-10286-3bo0kxnWaOQUvHkbgXJLS5sdmw4N0Rt+2LY78lusg7I@public.gmane.org/>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 7 Feb 2011 18:14:56 GMT
bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28532
> 
>            Summary: Link state change detection problem on Moschip MCS7832
>                     [mcs7830]
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.38-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>         ReportedBy: myxal.mxl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
>         Regression: No
> 
> 
> Created an attachment (id=46752)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=46752)
> lsusb -vv output
> 
> Hi.
> 
> I have a network adapter which uses the aforementioned driver and while
> checking for the link state via ethtool reports the correct state, many
> networking userspace utilities seem to have no clue about it (NM 0.8.1 starts
> dhclient BEFORE any cable is plugged) - and more importantly, don't notice when
> the cable is (dis)connected. Since there's not even a kernel message when
> (dis)connecting the cable, I suspect the driver does not implement Link state
> change detection at all. Is this accurate?
> 
> LSCD works in Windows, where it's apparently implemented through periodic
> polling (judging by virtualbox's blinking USB icon).
> How is this situation normally handled? Is it kernel's job to do the polling?
> Or are userspace utilities expected to do this?
> 
> Docs to the chip are available here:
> http://www.moschip.com/data/products/MCS7830/Data%20Sheet_7830.pdf
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
