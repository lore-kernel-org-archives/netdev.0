From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 12:03:49 +0100
Message-ID: <2321910.EQLkSoxl50@linux-5eaq.site>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no> <6505263.QGCG9bfoCC@linux-5eaq.site> <87bocehmzd.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87bocehmzd.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 24 January 2013 11:52:22 Bj=F8rn Mork wrote:
> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
>=20
> > On Thursday 24 January 2013 11:25:52 Bj=F8rn Mork wrote:
> >> The MBIM firmware for the Sierra Wireless MC7710 is a nice source
> >> of "interesting" device issues.  One of the uglier ones is that
> >> it under certain conditions will start flooding us with frames
> >> having length 0 as fast as it can.  And that is pretty fast...
> >
> > If you can tell that those frames are bogus, why not count them
> > as opposed to generic qlen? Say, if you see 20 among the last 30
> > are of this type, throttle.
>=20
> Sounds like a good idea, but where do I add/get that statistics?

rx_complete

It need not be very accurate.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
