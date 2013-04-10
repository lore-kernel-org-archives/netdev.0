From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 15:58:38 +0200
Message-ID: <21345916.cd7DzC6Ttz@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1542762.9EJvNHlBNo@linux-5eaq.site> <1365602083.28888.40.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365602083.28888.40.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 April 2013 08:54:43 Dan Williams wrote:
> > The refcounting is very good. Just don't mess around with "force"
> 
> That's easy to do if the helpers aren't used for suspend/resume, which
> is what I had previously in my v2 patches until Ming suggested that I
> use the helpers there.  I can go back to that approach if you'd like, it
> is a bit less complicated at the expense of sprinkling the interrupt urb
> submit/kill code around more widely.

If you introduce a third helper like "forcibly_stop_interrupt" or something,
I'll be perfectly happy. Just don't use flags which completely alter behavior.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
