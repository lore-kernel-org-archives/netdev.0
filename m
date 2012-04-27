From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 23:53:28 +0200
Message-ID: <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
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
	<20120427185809.GZ3157@wantstofly.org>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=14dae94ed85380d02804beb02247
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	Jim Cromie <jim.cromie@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120427185809.GZ3157@wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--14dae94ed85380d02804beb02247
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 27, 2012 at 8:58 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Fri, Apr 27, 2012 at 03:29:26PM +0200, Sedat Dilek wrote:
>
>> >>> >> >> >> Are you planning to or even working on support (for) 8361 d=
evices?
>> >>> >> >> >
>> >>> >> >> > I don't have any such plans, and I don't know of anyone who =
does.
>> >>> >> >>
>> >>> >> >> Does 8361 require firmware support?
>> >>> >> >
>> >>> >> > What do you mean by that?
>> >>> >>
>> >>> >> IIRC ath5k for example needs no external firmware file.
>> >>> >
>> >>> > The 8361 requires firmware to be loaded into it before it'll do
>> >>> > anything useful.
>> >>> >
>> >>> >
>> >>> >> >> Does a firmware file exist (name?)?
>> >>> >> >
>> >>> >> > There's firmware for the 8361 out there, however, that version =
of
>> >>> >> > the firmware implements a firmware API that is different from t=
he
>> >>> >> > one that mwl8k currently implements.
>> >>> >> >
>> >>> >> > You could add 8361 support to mwl8k, but then you'd have to go =
over
>> >>> >> > all the firmware command invocations in mwl8k and make sure tha=
t they
>> >>> >> > will work on the 8361 firmware that you're trying to support as=
 well.
>> >>> >>
>> >>> >> Without having a 8361 this will be even harder to walk through.
>> >>> >>
>> >>> >> Anyway, thanks for your detailed explanations.
>> >>> >>
>> >>> >> What's the alternative for such affected users?
>> >>> >> Use ndis-wrapper?
>> >>> >
>> >>> > I'm not sure. =C2=A0I've never tried to get a 8361 work under Linu=
x.
>> >>>
>> >>> Just found on [1] this same wrong patch in [2] :-).
>> >>> Dunno if [3] worked and from where they have stolen fw-files.
>> >>>
>> >>> - Sedat -
>> >>>
>> >>> [1] https://dev.openwrt.org/ticket/7209
>> >>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_id.=
patch
>> >>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.patch
>> >>
>> >> I doubt that [3] is really all that's needed to make it work. =C2=A0B=
ut if
>> >> there's someone for whom it works, I'd like them to run some tests on
>> >> mwl8k + [3] on 88w8361p.
>> >
>> > Just asked lautriv to do so (he will do against linux-3.3.3), lets' se=
e.
>> > Also, I refreshed and adapted a bit the instructions (see attachment).
>> >
>> > - Sedat -
>>
>> [ CC Jim Cromie ]
>>
>> Now, with extracted firmware files renamed & copied to
>> /lib/firmware/mwl8k/ and applied patch (see attachment) against
>> Linux-3.4-rc4+ I am seeing with modinfo:
>>
>> $ sudo modinfo mwl8k
>> filename:
>> /lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8k.ko
>> license: =C2=A0 =C2=A0 =C2=A0 =C2=A0GPL
>> author: =C2=A0 =C2=A0 =C2=A0 =C2=A0 Lennert Buytenhek <buytenh@marvell.c=
om>
>> version: =C2=A0 =C2=A0 =C2=A0 =C2=A00.13
>> description: =C2=A0 =C2=A0Marvell TOPDOG(R) 802.11 Wireless Network Driv=
er
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366_ap-2.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8366.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8687.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8687.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8363.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8363.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8361p.fw
>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8361p.fw
>> srcversion: =C2=A0 =C2=A0 9E1479A05C8D67E6AE90746
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A43sv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A40sv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A30sv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A2Bsv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A24sv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Csv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Asv*sd*bc*=
sc*i*
>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A02sv*sd*bc*=
sc*i* <--- 8361P:
>> 0x2a02 PCI device-id
>> depends: =C2=A0 =C2=A0 =C2=A0 =C2=A0mac80211,cfg80211
>> vermagic: =C2=A0 =C2=A0 =C2=A0 3.4.0-rc4-5-generic SMP mod_unload modver=
sions
>> parm: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ap_mode_default:Set to 1 to mak=
e ap mode the default
>> instead of sta mode (bool)
>>
>> $ ls -l /lib/firmware/mwl8k/
>> insgesamt 456
>> -rw-r--r-- 1 root root =C2=A075848 Apr 27 13:49 fmimage_8361p.fw <---
>> 8361P: Firmware image
>> -rw-r--r-- 1 root root 101780 M=C3=A4r 19 19:32 fmimage_8366_ap-1.fw
>> -rw-r--r-- 1 root root 101976 M=C3=A4r 19 19:32 fmimage_8366_ap-2.fw
>> -rw-r--r-- 1 root root =C2=A096664 M=C3=A4r 19 19:32 fmimage_8366.fw
>> -rw-r--r-- 1 root root =C2=A073252 Feb 23 20:07 fmimage_8687.fw
>> -rw-r--r-- 1 root root =C2=A0 2476 Apr 27 13:49 helper_8361p.fw <--- 836=
1P:
>> Helper image
>> -rw-r--r-- 1 root root =C2=A0 2476 M=C3=A4r 19 19:32 helper_8366.fw
>> -rw-r--r-- 1 root root =C2=A0 2476 Feb 23 20:07 helper_8687.fw
>>
>> As said... ***compile-tested*** only here.
>
> Which doesn't say much at all, but..
>

As already pointed out, no Marwell WLAN hardware here. Marvell comics
of course :-).

>
>> I had a short query with lautriv on #linux-wireless this afternoon:
>> * mwl8k kernel-module was autoloaded
>> * wlan0 interface got fired up
>> * ESSID was accepted
>> * logs reported 802.11bgn support is active
>> * (he tested on Linux-3.3.3)
>>
>> With WPA/WPA2 lautriv had some problems as his installation was
>> missing wpasupplicant.
>> He setup a classic /etc/network/interfaces.
>> After resetting his router mwl8k worked nicely.
>>
>> Unfortunately, he was on the run and promised me to send logs and do
>> more testing this evening.
>
> ..but this is pretty interesting. =C2=A0I thought that the only available
> 8361p firmware used an incompatible firmware API, and I didn't know
> of the existence of an apparently compatible firmware.
>
>
>> So, Lennert if you want more testing - What? How? etc.
>
> For one, the output of 'iw phy', please.
>
> Also, does monitor mode work? =C2=A0Do you get plausible channel/rxpower
> values in tcpdump in monitor mode?
>
> Are there any messages in the syslog about failing commands?
>
>
> thanks,
> Lennert

On 1st sight, logs look fine:

[21:52:52] <lautriv> [    6.050967] ieee80211 phy0: 88w8361p v4,
00173f3bdde3, STA firmware 2.1.4.25

But WLAN connection is not that fast and stable as lautriv reports
(several abnormalities were observed).

I requested a tarball which includes:
* dmesg (Linux-3.3.3)
* e_n_a (/etc/network/interfaces)
* ifconfig output
* iwconfig output
* iw_phy output
* ps_axu (WPA) output

lautriv will be so kind to be around on #linux-wireless/Freenode the
next days (UTC+2: German/Swiss local-time).
Just ping him.

Hope you have fun, together!

- Sedat -

--14dae94ed85380d02804beb02247
Content-Type: application/octet-stream; name="8361p.tar.xz"
Content-Disposition: attachment; filename="8361p.tar.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1jrq1wy0

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
--14dae94ed85380d02804beb02247--
