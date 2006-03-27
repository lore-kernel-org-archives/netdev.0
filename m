From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: 32bit compat for rtnetlink wireless extensions?
Date: Mon, 27 Mar 2006 13:17:54 -0800
Message-ID: <20060327211754.GB31813@bougret.hpl.hp.com>
References: <200603261408.48766.arnd@arndb.de> <20060327184242.GC31478@bougret.hpl.hp.com> <200603272310.44692.arnd@arndb.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751456AbWC0VSA@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200603272310.44692.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2006 at 11:10:44PM +0200, Arnd Bergmann wrote:
> Am Monday 27 March 2006 20:42 schrieb Jean Tourrilhes:
> > =A0=A0=A0=A0=A0=A0=A0=A0Actually, when things are passed over RtNet=
link, the pointer
> > is removed, and the content of IW_HEADER_TYPE_POINT is moved to not
> > leave a gap.
>=20
> Ah, that makes sense, thanks for the explanation.
>=20
> So if the wireless ioctl interface ever got retired, that code could
> get simplified a lot to just pass around a flat data structure, right=
?
>=20
> 	Arnd <><

	Actually, it could be removed *now*. You would just have to
fix all wireless drivers in existence. I will scratch my head to see
if we could plan a smooth transition.

	Jean
