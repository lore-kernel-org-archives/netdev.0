From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Sun, 29 Apr 2012 00:25:21 +0200
Message-ID: <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
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
	<CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf3074afa85cd73404bec4b2e0
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lautriv <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--20cf3074afa85cd73404bec4b2e0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 27, 2012 at 11:53 PM, Sedat Dilek
<sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
> On Fri, Apr 27, 2012 at 8:58 PM, Lennert Buytenhek
> <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org> wrote:
>> On Fri, Apr 27, 2012 at 03:29:26PM +0200, Sedat Dilek wrote:
>>
>>> >>> >> >> >> Are you planning to or even working on support (for) 8361 =
devices?
>>> >>> >> >> >
>>> >>> >> >> > I don't have any such plans, and I don't know of anyone who=
 does.
>>> >>> >> >>
>>> >>> >> >> Does 8361 require firmware support?
>>> >>> >> >
>>> >>> >> > What do you mean by that?
>>> >>> >>
>>> >>> >> IIRC ath5k for example needs no external firmware file.
>>> >>> >
>>> >>> > The 8361 requires firmware to be loaded into it before it'll do
>>> >>> > anything useful.
>>> >>> >
>>> >>> >
>>> >>> >> >> Does a firmware file exist (name?)?
>>> >>> >> >
>>> >>> >> > There's firmware for the 8361 out there, however, that version=
 of
>>> >>> >> > the firmware implements a firmware API that is different from =
the
>>> >>> >> > one that mwl8k currently implements.
>>> >>> >> >
>>> >>> >> > You could add 8361 support to mwl8k, but then you'd have to go=
 over
>>> >>> >> > all the firmware command invocations in mwl8k and make sure th=
at they
>>> >>> >> > will work on the 8361 firmware that you're trying to support a=
s well.
>>> >>> >>
>>> >>> >> Without having a 8361 this will be even harder to walk through.
>>> >>> >>
>>> >>> >> Anyway, thanks for your detailed explanations.
>>> >>> >>
>>> >>> >> What's the alternative for such affected users?
>>> >>> >> Use ndis-wrapper?
>>> >>> >
>>> >>> > I'm not sure. =C2=A0I've never tried to get a 8361 work under Lin=
ux.
>>> >>>
>>> >>> Just found on [1] this same wrong patch in [2] :-).
>>> >>> Dunno if [3] worked and from where they have stolen fw-files.
>>> >>>
>>> >>> - Sedat -
>>> >>>
>>> >>> [1] https://dev.openwrt.org/ticket/7209
>>> >>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_id=
.patch
>>> >>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.patc=
h
>>> >>
>>> >> I doubt that [3] is really all that's needed to make it work. =C2=A0=
But if
>>> >> there's someone for whom it works, I'd like them to run some tests o=
n
>>> >> mwl8k + [3] on 88w8361p.
>>> >
>>> > Just asked lautriv to do so (he will do against linux-3.3.3), lets' s=
ee.
>>> > Also, I refreshed and adapted a bit the instructions (see attachment)=
.
>>> >
>>> > - Sedat -
>>>
>>> [ CC Jim Cromie ]
>>>
>>> Now, with extracted firmware files renamed & copied to
>>> /lib/firmware/mwl8k/ and applied patch (see attachment) against
>>> Linux-3.4-rc4+ I am seeing with modinfo:
>>>
>>> $ sudo modinfo mwl8k
>>> filename:
>>> /lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8k.ko
>>> license: =C2=A0 =C2=A0 =C2=A0 =C2=A0GPL
>>> author: =C2=A0 =C2=A0 =C2=A0 =C2=A0 Lennert Buytenhek <buytenh@marvell.=
com>
>>> version: =C2=A0 =C2=A0 =C2=A0 =C2=A00.13
>>> description: =C2=A0 =C2=A0Marvell TOPDOG(R) 802.11 Wireless Network Dri=
ver
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366_ap-2.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8366.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8687.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8687.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8363.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8363.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8361p.fw
>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8361p.fw
>>> srcversion: =C2=A0 =C2=A0 9E1479A05C8D67E6AE90746
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A43sv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A40sv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A30sv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A2Bsv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A24sv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Csv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Asv*sd*bc=
*sc*i*
>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A02sv*sd*bc=
*sc*i* <--- 8361P:
>>> 0x2a02 PCI device-id
>>> depends: =C2=A0 =C2=A0 =C2=A0 =C2=A0mac80211,cfg80211
>>> vermagic: =C2=A0 =C2=A0 =C2=A0 3.4.0-rc4-5-generic SMP mod_unload modve=
rsions
>>> parm: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ap_mode_default:Set to 1 to ma=
ke ap mode the default
>>> instead of sta mode (bool)
>>>
>>> $ ls -l /lib/firmware/mwl8k/
>>> insgesamt 456
>>> -rw-r--r-- 1 root root =C2=A075848 Apr 27 13:49 fmimage_8361p.fw <---
>>> 8361P: Firmware image
>>> -rw-r--r-- 1 root root 101780 M=C3=A4r 19 19:32 fmimage_8366_ap-1.fw
>>> -rw-r--r-- 1 root root 101976 M=C3=A4r 19 19:32 fmimage_8366_ap-2.fw
>>> -rw-r--r-- 1 root root =C2=A096664 M=C3=A4r 19 19:32 fmimage_8366.fw
>>> -rw-r--r-- 1 root root =C2=A073252 Feb 23 20:07 fmimage_8687.fw
>>> -rw-r--r-- 1 root root =C2=A0 2476 Apr 27 13:49 helper_8361p.fw <--- 83=
61P:
>>> Helper image
>>> -rw-r--r-- 1 root root =C2=A0 2476 M=C3=A4r 19 19:32 helper_8366.fw
>>> -rw-r--r-- 1 root root =C2=A0 2476 Feb 23 20:07 helper_8687.fw
>>>
>>> As said... ***compile-tested*** only here.
>>
>> Which doesn't say much at all, but..
>>
>
> As already pointed out, no Marwell WLAN hardware here. Marvell comics
> of course :-).
>
>>
>>> I had a short query with lautriv on #linux-wireless this afternoon:
>>> * mwl8k kernel-module was autoloaded
>>> * wlan0 interface got fired up
>>> * ESSID was accepted
>>> * logs reported 802.11bgn support is active
>>> * (he tested on Linux-3.3.3)
>>>
>>> With WPA/WPA2 lautriv had some problems as his installation was
>>> missing wpasupplicant.
>>> He setup a classic /etc/network/interfaces.
>>> After resetting his router mwl8k worked nicely.
>>>
>>> Unfortunately, he was on the run and promised me to send logs and do
>>> more testing this evening.
>>
>> ..but this is pretty interesting. =C2=A0I thought that the only availabl=
e
>> 8361p firmware used an incompatible firmware API, and I didn't know
>> of the existence of an apparently compatible firmware.
>>
>>
>>> So, Lennert if you want more testing - What? How? etc.
>>
>> For one, the output of 'iw phy', please.
>>
>> Also, does monitor mode work? =C2=A0Do you get plausible channel/rxpower
>> values in tcpdump in monitor mode?
>>
>> Are there any messages in the syslog about failing commands?
>>
>>
>> thanks,
>> Lennert
>
> On 1st sight, logs look fine:
>
> [21:52:52] <lautriv> [ =C2=A0 =C2=A06.050967] ieee80211 phy0: 88w8361p v4=
,
> 00173f3bdde3, STA firmware 2.1.4.25
>
> But WLAN connection is not that fast and stable as lautriv reports
> (several abnormalities were observed).
>
> I requested a tarball which includes:
> * dmesg (Linux-3.3.3)
> * e_n_a (/etc/network/interfaces)
> * ifconfig output
> * iwconfig output
> * iw_phy output
> * ps_axu (WPA) output
>
> lautriv will be so kind to be around on #linux-wireless/Freenode the
> next days (UTC+2: German/Swiss local-time).
> Just ping him.
>
> Hope you have fun, together!
>
> - Sedat -

A new tarball from lautriv with same outputs as before, but now tested
with Linux-3.4-rc4.

- Sedat -

--20cf3074afa85cd73404bec4b2e0
Content-Type: application/octet-stream; name="8361p_3.4.0-rc4.tar.xz"
Content-Disposition: attachment; filename="8361p_3.4.0-rc4.tar.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1l8nvec1

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
OX8AAbNNgMACAAdrqLGxxGf7AgAAAAAEWVo=
--20cf3074afa85cd73404bec4b2e0--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
