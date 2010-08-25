From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 16821] New: g_ether no carrier while it is
Date: Tue, 24 Aug 2010 22:38:39 -0700 (PDT)
Message-ID: <559294.8951.qm@web180302.mail.gq1.yahoo.com>
References: <20100824164006.0bd7b7e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100824164006.0bd7b7e8.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



--- On Tue, 8/24/10, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Subject: Re: [Bugme-new] [Bug 16821] New: g_ether no carrier while it=
 is
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, bugme-daemon-590EEB7GvNgfezExeAdx9g@public.gmane.org=
=2Eorg, "Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "David Brownell" <david-b@pacbell.n=
et>, public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> Date: Tuesday, August 24, 2010, 4:40 PM
>=20
> (switched to email.=A0 Please respond via emailed
> reply-to-all, not via the
> bugzilla web interface).
>=20
> On Mon, 23 Aug 2010 06:24:16 GMT
> bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16821
> >=20
> >=A0 =A0 =A0 =A0 =A0 =A0 Summary:
> g_ether no carrier while it is
> >=A0 =A0 =A0 =A0 =A0 =A0 Product:
> Networking
> >=A0 =A0 =A0 =A0 =A0 =A0 Version: 2.5
> >=A0 =A0=A0=A0Kernel Version: 2.6.3(2 - ok,
> 3?, 4-6 - fail)
> >=A0 =A0 =A0 =A0 =A0=A0=A0Platform:
> All
> >=A0 =A0 =A0 =A0=A0=A0OS/Version:
> Linux
> >=A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0Tree: Mainline
> >=A0 =A0 =A0 =A0 =A0
> =A0=A0=A0Status: NEW
> >=A0 =A0 =A0 =A0 =A0=A0=A0Severity:
> blocking
> >=A0 =A0 =A0 =A0 =A0=A0=A0Priority:
> P1
> >=A0 =A0 =A0 =A0 =A0 Component: Other
> >=A0 =A0 =A0 =A0=A0=A0AssignedTo: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org
> >=A0 =A0 =A0 =A0=A0=A0ReportedBy: public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> >=A0 =A0 =A0 =A0=A0=A0Regression: Yes
> >=20
> >=20
> > After successfully loaded g_ether module (with
> use_eem=3D0) usb device appears.
> > If I configure it at host as ifconfig usb0 blah bah,
> than network present, all
> > ok.=20
> > In windows (with RNDIS config), and in linux with
> bridge it looks to CARRIER
> > state. I get in ip addr state DOWN, NO-CARRIER. That's
> why g_ether usb device
> > in bridge and windows don't work at all.
>=20
> So g_ether broke after 2.6.32?
>=20
> Nobody really seems to do much with that USB driver.

That's changed then.  There used to be boxes that
relied on it for their network connectivity...

Adding EEM support was something... I think the
issue might be driver changes since last it was
seriously tested in bridge configs (for which
the link state, such as carrier, matters LOTS.)


> I wonder if some
> changes in core networking could have triggered this?

Wouldn't be my first thought; but might be.

ISTR getting link/carrier state to behave in
the first place (with just CDC and RNDIS) was
complex.  If it wasn't carefully re-tested after
EEM was added, breakage may have been overlooked.

- Dave

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
