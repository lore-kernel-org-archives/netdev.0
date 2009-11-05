From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Subject: Re: Shared i2c adapter locking
Date: Thu, 5 Nov 2009 15:07:15 +0100
Message-ID: <20091105150715.692b5200@hyperion.delvare>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	<20091029154317.651904b9@hyperion.delvare>
	<1256828976.2827.27.camel@achroite>
	<20091105141122.56b6b4f8@hyperion.delvare>
	<1257429444.2793.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mika Kuoppala <mika.kuoppala-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Linux I2C <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1257429444.2793.2.camel-xQnnTUlwzDrdvaEqJLTMTA9jg9n5Vt1AMm0uRHvK7Nw@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 05 Nov 2009 13:57:24 +0000, Ben Hutchings wrote:
> On Thu, 2009-11-05 at 14:11 +0100, Jean Delvare wrote:
> [...]
> > What about the following patch?
> >=20
> > From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
> > Subject: i2c: Add an interface to lock/unlock I2C bus segment
> >=20
> > Some drivers need to be able to prevent access to an I2C bus segmen=
t
> > for a specific period of time. Add an interface for them to do so
> > without twiddling with i2c-core internals.
> >=20
> > Signed-off-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
> > Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> Acked-by: =EF=BB=BFBen Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
>=20
> Presumably this is meant for net-next-2.6, and you'll implement

Actually I meant to push this to Linus immediately, through my i2c
tree. This is essentially a no-op: the binary code will be the same as
before the patch, so guaranteed to be safe, and this will solve
conflicts in linux-next.

> i2c_{lock,unlock}_adapter() using rt_mutex in your i2c tree?

Correct.

--=20
Jean Delvare
