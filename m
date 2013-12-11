From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH v2 01/16] wl1251: fix scan behaviour while not associated
Date: Wed, 11 Dec 2013 20:44:40 +0000
Message-ID: <1386794680.1516.249.camel@bwh-desktop.uk.level5networks.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <20131210092114.GB22756@amd.pavel.ucw.cz>
	 <8738m0r9wv.fsf@purkki.adurom.net> <201312101808.44713@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	"Luciano Coelho" <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <freemangordon-uiMcrn6V0Vs@public.gmane.org>,
	<aaro.koskinen-X3B1VOXEql0@public.gmane.org>, <sre-GFxCN5SEZAc@public.gmane.org>,
	<joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201312101808.44713@pali>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 18:08 +0100, Pali Roh=C3=A1r wrote:
> On Tuesday 10 December 2013 16:41:04 Kalle Valo wrote:
> > Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> writes:
> > > ssids can have \0s in them... and what is worse, they may
> > > not be 0 terminated AFAICT.
> > >=20
> > > Potential solution is at
> > > http://www.spinics.net/lists/linux-wireless/msg98640.html .
> >=20
> > I just use print_hex_dump_bytes() to print SSIDs.
>=20
> Ok and has kernel printf modifier for size_t?

It is 'z', same as in userland.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
