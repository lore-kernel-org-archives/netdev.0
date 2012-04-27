From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 20:58:09 +0200
Message-ID: <20120427185809.GZ3157@wantstofly.org>
References: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
 <20120427094007.GU3157@wantstofly.org>
 <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
 <20120427094637.GV3157@wantstofly.org>
 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org>
 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
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
In-Reply-To: <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 03:29:26PM +0200, Sedat Dilek wrote:

> >>> >> >> >> Are you planning to or even working on support (for) 836=
1 devices?
> >>> >> >> >
> >>> >> >> > I don't have any such plans, and I don't know of anyone w=
ho does.
> >>> >> >>
> >>> >> >> Does 8361 require firmware support?
> >>> >> >
> >>> >> > What do you mean by that?
> >>> >>
> >>> >> IIRC ath5k for example needs no external firmware file.
> >>> >
> >>> > The 8361 requires firmware to be loaded into it before it'll do
> >>> > anything useful.
> >>> >
> >>> >
> >>> >> >> Does a firmware file exist (name?)?
> >>> >> >
> >>> >> > There's firmware for the 8361 out there, however, that versi=
on of
> >>> >> > the firmware implements a firmware API that is different fro=
m the
> >>> >> > one that mwl8k currently implements.
> >>> >> >
> >>> >> > You could add 8361 support to mwl8k, but then you'd have to =
go over
> >>> >> > all the firmware command invocations in mwl8k and make sure =
that they
> >>> >> > will work on the 8361 firmware that you're trying to support=
 as well.
> >>> >>
> >>> >> Without having a 8361 this will be even harder to walk through=
=2E
> >>> >>
> >>> >> Anyway, thanks for your detailed explanations.
> >>> >>
> >>> >> What's the alternative for such affected users?
> >>> >> Use ndis-wrapper?
> >>> >
> >>> > I'm not sure. =A0I've never tried to get a 8361 work under Linu=
x.
> >>>
> >>> Just found on [1] this same wrong patch in [2] :-).
> >>> Dunno if [3] worked and from where they have stolen fw-files.
> >>>
> >>> - Sedat -
> >>>
> >>> [1] https://dev.openwrt.org/ticket/7209
> >>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_=
id.patch
> >>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.pa=
tch
> >>
> >> I doubt that [3] is really all that's needed to make it work. =A0B=
ut if
> >> there's someone for whom it works, I'd like them to run some tests=
 on
> >> mwl8k + [3] on 88w8361p.
> >
> > Just asked lautriv to do so (he will do against linux-3.3.3), lets'=
 see.
> > Also, I refreshed and adapted a bit the instructions (see attachmen=
t).
> >
> > - Sedat -
>=20
> [ CC Jim Cromie ]
>=20
> Now, with extracted firmware files renamed & copied to
> /lib/firmware/mwl8k/ and applied patch (see attachment) against
> Linux-3.4-rc4+ I am seeing with modinfo:
>=20
> $ sudo modinfo mwl8k
> filename:
> /lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8k.ko
> license:        GPL
> author:         Lennert Buytenhek <buytenh@marvell.com>
> version:        0.13
> description:    Marvell TOPDOG(R) 802.11 Wireless Network Driver
> firmware:       mwl8k/fmimage_8366_ap-2.fw
> firmware:       mwl8k/fmimage_8366.fw
> firmware:       mwl8k/helper_8366.fw
> firmware:       mwl8k/fmimage_8687.fw
> firmware:       mwl8k/helper_8687.fw
> firmware:       mwl8k/fmimage_8363.fw
> firmware:       mwl8k/helper_8363.fw
> firmware:       mwl8k/fmimage_8361p.fw
> firmware:       mwl8k/helper_8361p.fw
> srcversion:     9E1479A05C8D67E6AE90746
> alias:          pci:v000011ABd00002A43sv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A40sv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A30sv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A2Bsv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A24sv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A0Csv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A0Asv*sd*bc*sc*i*
> alias:          pci:v000011ABd00002A02sv*sd*bc*sc*i* <--- 8361P:
> 0x2a02 PCI device-id
> depends:        mac80211,cfg80211
> vermagic:       3.4.0-rc4-5-generic SMP mod_unload modversions
> parm:           ap_mode_default:Set to 1 to make ap mode the default
> instead of sta mode (bool)
>=20
> $ ls -l /lib/firmware/mwl8k/
> insgesamt 456
> -rw-r--r-- 1 root root  75848 Apr 27 13:49 fmimage_8361p.fw <---
> 8361P: Firmware image
> -rw-r--r-- 1 root root 101780 M=E4r 19 19:32 fmimage_8366_ap-1.fw
> -rw-r--r-- 1 root root 101976 M=E4r 19 19:32 fmimage_8366_ap-2.fw
> -rw-r--r-- 1 root root  96664 M=E4r 19 19:32 fmimage_8366.fw
> -rw-r--r-- 1 root root  73252 Feb 23 20:07 fmimage_8687.fw
> -rw-r--r-- 1 root root   2476 Apr 27 13:49 helper_8361p.fw <--- 8361P=
:
> Helper image
> -rw-r--r-- 1 root root   2476 M=E4r 19 19:32 helper_8366.fw
> -rw-r--r-- 1 root root   2476 Feb 23 20:07 helper_8687.fw
>=20
> As said... ***compile-tested*** only here.

Which doesn't say much at all, but..


> I had a short query with lautriv on #linux-wireless this afternoon:
> * mwl8k kernel-module was autoloaded
> * wlan0 interface got fired up
> * ESSID was accepted
> * logs reported 802.11bgn support is active
> * (he tested on Linux-3.3.3)
>=20
> With WPA/WPA2 lautriv had some problems as his installation was
> missing wpasupplicant.
> He setup a classic /etc/network/interfaces.
> After resetting his router mwl8k worked nicely.
>=20
> Unfortunately, he was on the run and promised me to send logs and do
> more testing this evening.

=2E.but this is pretty interesting.  I thought that the only available
8361p firmware used an incompatible firmware API, and I didn't know
of the existence of an apparently compatible firmware.


> So, Lennert if you want more testing - What? How? etc.

=46or one, the output of 'iw phy', please.

Also, does monitor mode work?  Do you get plausible channel/rxpower
values in tcpdump in monitor mode?

Are there any messages in the syslog about failing commands?


thanks,
Lennert
