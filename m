From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH v3] CDC NCM: release interfaces fix in unbind()
Date: Tue, 24 May 2011 15:27:30 +0200
Message-ID: <201105241527.30270.oneukum@suse.de>
References: <1305938536-5343-1-git-send-email-alexey.orishko@stericsson.com> <20110523.174647.1404735155326791304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110523.174647.1404735155326791304.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 23. Mai 2011, 23:46:47 schrieb David Miller:
> From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat, 21 May 2011 02:42:16 +0200
>=20
> > Changes:
> > - claim slave/data interface during bind() and release
> >  interfaces in unbind() unconditionally
> > - in case of error during bind(), release claimed data
> >  interface in the same function
> > - remove obsolited "*_claimed" entries from driver context
> >=20
> > Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
>=20
> Oliver, this look good to you?

I'd like to see intfdata set to NULL before an interface is unclaimed.

	Regards
		Oliver

--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
