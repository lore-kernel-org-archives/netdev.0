From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 11 Feb 2005 00:04:11 -0500
Message-ID: <200502110004.12133.dtor_core@ameritech.net>
References: <20050131102920.GC4170@suse.de> <20050210012304.E25338@almesberger.net> <20050210195026.09b507e7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Werner Almesberger <wa@almesberger.net>,
	herbert@gondor.apana.org.au, anton@samba.org, okir@suse.de,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262127AbVBKFER@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050210195026.09b507e7.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 10 February 2005 22:50, David S. Miller wrote:
> > > Unlike the above routines, it is required that explicit memory
> > > barriers are performed before and after the operation. =A0It must
> > > be done such that all memory operations before and after the
> > > atomic operation calls are strongly ordered with respect to the
> > > atomic operation itself.
> >=20
> > Hmm, given that this description will not only be read by implement=
ers
> > of atomic functions, but also by users, the "explicit memory barrie=
rs"
> > may be confusing.
>=20
> Absolutely, I agree. =A0My fingers even itched as I typed those lines
> in. =A0I didn't change the wording because I couldn't come up with
> anything better.

What about the following:

Unlike the routines above, these functions should always perform memory
barriers before and after the operation in question so that all memory
accesses before and after the atomic operation are strongly ordered wit=
h
respect to the atomic operation itself.

--=20
Dmitry
