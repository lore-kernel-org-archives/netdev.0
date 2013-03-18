From: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Mon, 18 Mar 2013 15:19:14 -0300
Message-ID: <20130318181914.GC3072@joana>
References: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
 <20130313.053145.2200448840921851390.davem@davemloft.net>
 <CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA@mail.gmail.com>
 <CAPWTe+Kfr=zD6oJsfX3W8Ze1iH+CoEHx5FXo4YaVtQuMHD5k_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i0/AhcQY5QxfSsSZ"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Silviu Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAPWTe+Kfr=zD6oJsfX3W8Ze1iH+CoEHx5FXo4YaVtQuMHD5k_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Silviu,

* Silviu Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2013-03-18 20:13:50 +0200]:

> On Mon, Mar 18, 2013 at 8:05 PM, Silviu Popescu
> <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Wed, Mar 13, 2013 at 11:31 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wr=
ote:
> >> From: Silviu-Mihai Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Date: Tue, 12 Mar 2013 20:13:15 +0200
> >>
> >>> @@ -590,10 +590,7 @@ int __init bt_sysfs_init(void)
> >>>       bt_debugfs =3D debugfs_create_dir("bluetooth", NULL);
> >>>
> >>>       bt_class =3D class_create(THIS_MODULE, "bluetooth");
> >>> -     if (IS_ERR(bt_class))
> >>> -             return PTR_ERR(bt_class);
> >>> -
> >>> -     return 0;
> >>> +     return PTR_RET(bt_class)
> >>
> >> Don't bother submitting patches you aren't even going to try
> >> to compile.
> >>
> >> I'm rejecting all of your current submissions.  Resubmit them
> >> when you feel like typing 'make' from time to time.
> >>
> >>
> >
> > Sorry for the trouble caused and sorry for the late reply.
> > That being said, I'd like to understand a bit better what exactly I mes=
sed up.
> > I've just pulled the latest revision of the mainline kernel and made
> > the changes in this patch.
> > I've tried with make defconfig (which would be x86_64_defconfig in my
> > case), followed by
> > make menuconfig to select the bluetooth options and make allyesconfig.
> > Both defconfig and allyesconfig compile successfully on my system.
> > Would you be so kind as to tell me what error you have encountered?
> > Or perhaps enlighten me as to what I'm still doing wrong. I'd like to
> > learn from my mistakes.
>=20
> Please ignore this gratuitous stupidity.
> The right patch was applied locally, the wrong one sent to the list.
> I'll resubmit the proper one.

Someone already sent me a similar patch, so this is already fixed in
bluetooth-next. No need to resubmit this one.

	Gustavo

--i0/AhcQY5QxfSsSZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRR1qhAAoJEPs3PUX4s20oa8QQAJZa2lrQZNMpw2j8bkmBOcnX
CtHlczrgcaeZ1dhoNBeRf107pFNxO103OFynP5zPpVBOW7OifzFdpH82ch1CuBnM
QICCjnUE4PfNfEclIA/hRgROhMbvKqtoxt0I7+qeENU1twCuz79HU1yju48tkgZu
sqPI7XistdSf5/eEceW7j8mmOuIB6PuYORp4UCckft0N1hUJ/3sArEwipJiouM2k
gi5FITpXMhLKdi09bDl5L6u3e3YrON2dYBT0p9lIxu2bMWBNR1gMB8JzEqJmiZJ8
6jd/7vWMTo0wyzKY6tAAmIpUvxBw2ZzZakpd244sWjiZzEgOng2FqpQuvkhxYhEx
wqIDv94YUBUzaHdRRySBNEHknCtWFkxmnVwaswPS6z84TlciXRyJ9jOaTqpJoe/e
elUR4sVNpfRSN2IwPcxGDQjbSSzeATn1ur1x2j2rpqFGUCQ5AZf3uV1dVp6gZmtI
RhNjSJMLIh/NDf3a4caiXd4iDcrehP2dBeUYQqM10i32blzN6hM8A3ZXD/RggcW4
85KFKbgSnFFOfbfJt/FjJ+ucMIWZMjY1kOSRJ1QPA5Ak+9MDcyyE8tu+iR3nMb+1
L9JOxkN5A6M2sKDJX4UGCVuegBVSZx5k8l0YT4rx6FjIbp94mrye/qQrQO0Wa7Hc
uib9DTyMVARX4FoRUVlq
=yGa3
-----END PGP SIGNATURE-----

--i0/AhcQY5QxfSsSZ--
