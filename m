From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Sudden kernel panic with skge in 3.3-rc2
Date: Mon, 6 Feb 2012 16:17:57 -0800
Message-ID: <20120206161757.6eac9277@nehalam.linuxnetplumber.net>
References: <20120202192115.GA8480@elliptictech.com>
	<20120202124529.3e274223@s6510.linuxnetplumber.net>
	<CAP=VYLp6Kh7OtN0nsTBDkvTvNLMV0jymAmbR0tJX4r-yMdTSQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLp6Kh7OtN0nsTBDkvTvNLMV0jymAmbR0tJX4r-yMdTSQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Feb 2012 19:11:27 -0500
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On Thu, Feb 2, 2012 at 3:45 PM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
>=20
> [...]
>=20
> >
> > Try reverting this commit, it seems problematic
> > commit d0249e44432aa0ffcf710b64449b8eaa3722547e
> > Author: stephen hemminger <shemminger@vyatta.com>
> > Date: =A0 Thu Jan 19 14:37:18 2012 +0000
> >
> > =A0 =A0skge: check for PCI dma mapping errors
> >
>=20
> I'm seeing similar issues, and a revert of the above caused the
> problems to go away.  I'm testing on a baseline of net-next
> as of today (3238a9be4d7a) plus some TIPC patches I was
> trying to test (which are 99.9% unrelated to this, I'm sure).
>=20
> Details captured from serial console are below.  100% reproducible.
>=20
> I can probably try a test/debug patch for you if need be.
>=20
> Paul.

There is a simple bug in the cleanup code reordering. And it is
reproducible here. Working on a better solution.
