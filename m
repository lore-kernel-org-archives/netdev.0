From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Mon, 07 Jan 2013 08:40:22 +0100
Message-ID: <2543834.K7XJaOec6G@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1357349193.19684.3.camel@dcbw.foobar.com> <87y5g7nbej.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y5g7nbej.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 05 January 2013 11:59:16 Bj=F8rn Mork wrote:

Hi,

> You can still use a trick similar to what qmi_wwan and cdc_mbim does =
to
> take over the status endpoint from usbnet: By not implementing .statu=
s,
> and possibly setting dev->status to NULL in .bind, you are free to
> handle the status endpoint entirely inside the minidriver.  Not sure =
if
> that is smart though.  You would have to reimplement init_status and
> intr_complete from usbnet, and kill or resubmit the interrupt urb on
> suspend/resume/disconnect yourself.

Please no. We don't look for ways to circumvent frameworks. We alter
frameworks to act as we need them to act.

> The new usbnet flag is probably a better solution.

Indeed.

> FWIW, I agree with Oliver that always submitting the interrupt URB is
> both risky and will cause too much unnecessary USB activity for most
> usbnet devices.

Good.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
