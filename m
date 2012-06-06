From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] net: sierra_net: device IDs for Aircard 320U++
Date: Wed, 6 Jun 2012 21:16:33 +0900
Message-ID: <20120606121633.GB8535@kroah.com>
References: <20120605212414.GB6526@kroah.com>
 <1338967090-7119-1-git-send-email-bjorn@mork.no>
 <20120606081246.GB7306@kroah.com>
 <87wr3kua2k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wr3kua2k.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2012 at 10:19:15AM +0200, Bj=F8rn Mork wrote:
> Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> writes:
> > On Wed, Jun 06, 2012 at 09:18:10AM +0200, Bj=F8rn Mork wrote:
> >> Adding device IDs for Aircard 320U and two other devices
> >> found in the out-of-tree version of this driver.
> >>=20
> >> Cc: linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
> >> Cc: Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Cc: Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> >> ---
> >>  drivers/net/usb/sierra_net.c |   14 ++++++++++----
> >>  1 file changed, 10 insertions(+), 4 deletions(-)
> >
> > Wait, Tom just sent me a patch adding these device ids to the sierr=
a
> > serial driver, why would the same device work for both drivers?
>=20
> Because it's a composite device.  Was this a trick question? :-)
>=20
> >  Where should the device id go?
>=20
> To both drivers.  The device is similar to the 1199:68a3 device alrea=
dy
> supported by both drivers.  It has a number of serial ports (dependin=
g
> on how many features like GPS etc is enabled) supported by the "sierr=
a"
> driver and one ethernet interface speaking Sierra's HIP protocol
> supported by the "sierra_net" driver.

Ok, thanks for clearing that up, I'll take the serial patch, and I'm
sure that David will take this one.

	Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
