From: Borislav Petkov <bp@alien8.de>
Subject: Re: 3.9-rc3 forcedeth lockdep splat with netconsole
Date: Wed, 20 Mar 2013 12:58:31 +0100
Message-ID: <20130320115831.GC15471@pd.tnic>
References: <20130320110150.GB15471@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: ML netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130320110150.GB15471@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 20, 2013 at 12:01:51PM +0100, Borislav Petkov wrote:
> Hi,
>=20
> when trying to log stuff with netconsole, I get the following:
>=20
> [ =E2=80=A6 ]
>=20
> [    2.036977] netpoll: netconsole: device eth0 not up yet, forcing i=
t
> [    2.037632] forcedeth 0000:00:08.0: irq 42 for MSI/MSI-X
> [    2.037763] forcedeth 0000:00:08.0 eth0: MSI enabled
> [    2.038074] forcedeth 0000:00:08.0 eth0: no link during initializa=
tion
> [    2.780061] forcedeth 0000:00:08.0 eth0: link up

Hehe,

so it is actually funny to see the things lockdep is warning about,
in action: I was just able to hang the box with the last line above
appearing on the screen.

=46un.

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
