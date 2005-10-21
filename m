From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 16:42:53 -0400
Message-ID: <20051021204251.GC28212@tuxdriver.com>
References: <43592FE5.20106@colorfullife.com> <20051021202908.GA18966@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>,
        Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20051021202908.GA18966@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2005 at 10:29:08PM +0200, Francois Romieu wrote:
> Manfred Spraul <manfred@colorfullife.com> :
> > The current forcedeth driver doesn't support interrupt mitigation, th=
is=20
> > can result in an incredible number of interrupts/sec for gigabit link=
s.=20
> > The attached patch adds a throughput mode that enables an interrupt=20
> > mitigation scheme.
>=20
> Na=EFve question: what about the NAPI way ?

I was thinking the same thing...although it appears forcedeth already
supports NAPI...

What does this offer over the NAPI support?

John
--=20
John W. Linville
linville@tuxdriver.com
