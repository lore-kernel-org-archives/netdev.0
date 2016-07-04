From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH net,stable] cdc_ncm: workaround for EM7455 "silent" data
 interface
Date: Mon, 04 Jul 2016 15:00:01 +0200
Message-ID: <1467637201.9978.11.camel@suse.com>
References: <1467577490-27810-1-git-send-email-bjorn@mork.no>
	 <1467619605.9978.4.camel@suse.com> <87h9c5638l.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, metze-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87h9c5638l.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-07-04 at 13:40 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org> writes:
> > On Sun, 2016-07-03 at 22:24 +0200, Bj=C3=B8rn Mork wrote:
> >> Several Lenovo users have reported problems with their Sierra
> >> Wireless EM7455 modem. The driver has loaded successfully and
> >> the MBIM management channel has appeared to work, including
> >> establishing a connection to the mobile network. But no frames
> >> have been received over the data interface.
> >
> > If this is needed in open() it must also be needed in reset_resume(=
)
>=20
> reset_resume needs fixing in general. This is completely unrelated to
> this bug. In fact, as we don't do any NCM control messages there in t=
he

I see. In general this would be a problem.

> current resume, I'm not sure this firmware bug is triggered by it.  B=
ut
> it's untestable, because:

OK, something needs to be done, but this patch is not the place to do
it.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
