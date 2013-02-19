From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 17:47:41 +0200
Message-ID: <20130219154741.GH4390@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <201302191434.40495.arnd@arndb.de>
 <20130219150500.GG4390@arwen.pp.htv.fi>
 <201302191528.17698.arnd@arndb.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82evfD9Ogz2JrdWZ"
Cc: <balbi@ti.com>, kishon <kishon@ti.com>, <rob@landley.net>,
	<tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201302191528.17698.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--82evfD9Ogz2JrdWZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 19, 2013 at 03:28:17PM +0000, Arnd Bergmann wrote:
> On Tuesday 19 February 2013, Felipe Balbi wrote:
> > On Tue, Feb 19, 2013 at 02:34:40PM +0000, Arnd Bergmann wrote:
> > > On Tuesday 19 February 2013, Felipe Balbi wrote:
> > > > On Tue, Feb 19, 2013 at 12:33:54PM +0000, Arnd Bergmann wrote:
> > > It's a fine line, but I think a phy is something that resembles a dev=
ice
> > > more than an LED does. When I read patch 1, I also noticed and commen=
ted
> > > on the fact that it does use a 'class'. Now, according to Greg, we sh=
ould
> > > use 'bus_type' instead of 'class' in new code. I originally disagreed=
 with
> > > that concept, but he's the boss here and it's good if he has a vision
> > > how things should be lined out.
> > >=20
> > > In practice, there is little difference between a 'bus_type' and a 'c=
lass',
> > > so just replace any instance of the former with the latter in your he=
ad
> > > when reading the code ;-)
> >=20
> > it's not so simple :-) if we must use bus_type we need to introduce all
> > the device/driver matching mechanism which isn't necessary with a class.
>=20
> I think the idea is to use a bus_type that has devices but no drivers
> associated with it, but I might be misremembering things.

but then drivers wouldn't probe ever, although devices would get
created, so maybe it'll work...

> > Greg, can you pitch your suggestion here ? It would be great to hear
> > your rationale behind dropping class infrastructure, couldn't find
> > anything through Google and since feature-removal-schedule.txt has been
> > removed (without adding it to feature-removal-schedule.txt, I must add
> > :-) I don't know what's the idea behind removing classes.
>=20
> I believe for now, the idea is to not add any new classes, but keep
> the existing ones for compatibility. 'struct class_device' however
> was already removed and got turned into 'struct device'.

was there ever a "struct class_device".

What about struct class ?

<linux/device.h> ::

 334 struct class {
 335         const char              *name;
 336         struct module           *owner;
 337=20
 338         struct class_attribute          *class_attrs;
 339         struct device_attribute         *dev_attrs;
 340         struct bin_attribute            *dev_bin_attrs;
 341         struct kobject                  *dev_kobj;
 342=20
 343         int (*dev_uevent)(struct device *dev, struct kobj_uevent_env *=
env);
 344         char *(*devnode)(struct device *dev, umode_t *mode);
 345=20
 346         void (*class_release)(struct class *class);
 347         void (*dev_release)(struct device *dev);
 348=20
 349         int (*suspend)(struct device *dev, pm_message_t state);
 350         int (*resume)(struct device *dev);
 351=20
 352         const struct kobj_ns_type_operations *ns_type;
 353         const void *(*namespace)(struct device *dev);
 354=20
 355         const struct dev_pm_ops *pm;
 356=20
 357         struct subsys_private *p;
 358 };

--=20
balbi

--82evfD9Ogz2JrdWZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI56dAAoJEIaOsuA1yqRERe4P+gMQCYwuC9OhRMrgMN2uUu7d
tPkvx0cgg1EmOe2mRZ7d3nfWuvRZ1ztOaO0USeNAHWvPBNQM46MpRnUK5jYV/ETP
ObzzwAoVwm7efb8qwglqN/rgFutdV/xvW3X0WBVsRg7exi1DywI5WZUn98d14hiJ
OdSwO7MQsJzrwWG3At8W+LPSnrUYO9sUMF/kzICYca9jeGcKPZEGW7/y/DgoSOxk
am5+WXbJdd6oK2I7eg74T3FE3AJu+D4STEKXY+6U0sQDL3kyOeJafln9QL2ooKmr
lelv466SZ9LeXpRwOig66BHzZ1SOfwB2mHgO9IFwJpvmqlCQONjK16RTmus99Goq
Id+JPtESyPhxXBixQmctoI51nQBNeWndlrEt6+pg7dPRKz3ObsmHTpNR7eH1MXem
dlxTYVluH4zIn/HmJUci/cjh0eFCn6f5Fpbc5Vg+Zu6SGrOoSLeKmd1tdhpyFHIV
c6XFjMX4YBjO2FWlK4NkU1DOPEjzJS8X3m0sqL8Ut++xZNnVEQZXgfN1W8BoL2x+
FHoz7I9pSdxaH6JZyU3xtb6wPteVidhz3R4BOj6nDwPLmxeIzKHlLuarP9Vac7Td
y2xu1zhgrWOqDozaFnD64NR+Dj+wid1iIJm1dXqeksrd8xX9Vo4tyvInUDbasnmR
ONdL8dw6YVx7gEwHXNxi
=6JTv
-----END PGP SIGNATURE-----

--82evfD9Ogz2JrdWZ--
