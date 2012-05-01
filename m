From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Tue, 1 May 2012 14:47:08 +0200
Message-ID: <20120501124708.GM3157@wantstofly.org>
References: <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
 <20120427094637.GV3157@wantstofly.org>
 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org>
 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org>
 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	Jim Cromie <jim.cromie@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 11:53:28PM +0200, Sedat Dilek wrote:

> >> So, Lennert if you want more testing - What? How? etc.
> >
> > For one, the output of 'iw phy', please.
> >
> > Also, does monitor mode work? =A0Do you get plausible channel/rxpow=
er
> > values in tcpdump in monitor mode?
> >
> > Are there any messages in the syslog about failing commands?
>=20
> On 1st sight, logs look fine:
>=20
> [21:52:52] <lautriv> [    6.050967] ieee80211 phy0: 88w8361p v4,
> 00173f3bdde3, STA firmware 2.1.4.25
>=20
> But WLAN connection is not that fast and stable as lautriv reports
> (several abnormalities were observed).

iwconfig saying "Bit Rate=3D1 Mb/s" can be safely ignored.  If there is
a bitrate indication on transmitted packets in tcpdump, then that's
bogus too, as rate control is done in hardware.  (I.e. if you want to
verify the rate at which a packet is transmitted, you'll have to sniff
from another machine.)
