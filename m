From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Sun, 29 Apr 2012 00:49:30 +0200
Message-ID: <CA+icZUVT6kvqj47x26FU2qjbMHc=jr9_Lso=zduf_cmcSrv=UQ@mail.gmail.com>
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
	<CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
	<CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	lautriv <admin@coldplug.net>
To: Jim Cromie <jim.cromie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:56346 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab2D1Wtb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 18:49:31 -0400
In-Reply-To: <CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 29, 2012 at 12:36 AM, Jim Cromie <jim.cromie@gmail.com> wro=
te:
> [dropped lkml from cc]
>
> On Sat, Apr 28, 2012 at 4:25 PM, Sedat Dilek <sedat.dilek@googlemail.=
com> wrote:
>> On Fri, Apr 27, 2012 at 11:53 PM, Sedat Dilek
>> <sedat.dilek@googlemail.com> wrote:
>>> On Fri, Apr 27, 2012 at 8:58 PM, Lennert Buytenhek
>>> <buytenh@wantstofly.org> wrote:
>>>> On Fri, Apr 27, 2012 at 03:29:26PM +0200, Sedat Dilek wrote:
>>>>
>>>>> >>> >> >> >> Are you planning to or even working on support (for)=
 8361 devices?
>>>>> >>> >> >> >
>>>>> >>> >> >> > I don't have any such plans, and I don't know of anyo=
ne who does.
>>>>> >>> >> >>
>>>>> >>> >> >> Does 8361 require firmware support?
>>>>> >>> >> >
>>>>> >>> >> > What do you mean by that?
>>>>> >>> >>
>>>>> >>> >> IIRC ath5k for example needs no external firmware file.
>>>>> >>> >
>>>>> >>> > The 8361 requires firmware to be loaded into it before it'l=
l do
>>>>> >>> > anything useful.
>>>>> >>> >
>>>>> >>> >
>>>>> >>> >> >> Does a firmware file exist (name?)?
>>>>> >>> >> >
>>>>> >>> >> > There's firmware for the 8361 out there, however, that v=
ersion of
>>>>> >>> >> > the firmware implements a firmware API that is different=
 from the
>>>>> >>> >> > one that mwl8k currently implements.
>>>>> >>> >> >
>>>>> >>> >> > You could add 8361 support to mwl8k, but then you'd have=
 to go over
>>>>> >>> >> > all the firmware command invocations in mwl8k and make s=
ure that they
>>>>> >>> >> > will work on the 8361 firmware that you're trying to sup=
port as well.
>>>>> >>> >>
>>>>> >>> >> Without having a 8361 this will be even harder to walk thr=
ough.
>>>>> >>> >>
>>>>> >>> >> Anyway, thanks for your detailed explanations.
>>>>> >>> >>
>>>>> >>> >> What's the alternative for such affected users?
>>>>> >>> >> Use ndis-wrapper?
>>>>> >>> >
>>>>> >>> > I'm not sure. =C2=A0I've never tried to get a 8361 work und=
er Linux.
>>>>> >>>
>>>>> >>> Just found on [1] this same wrong patch in [2] :-).
>>>>> >>> Dunno if [3] worked and from where they have stolen fw-files.
>>>>> >>>
>>>>> >>> - Sedat -
>>>>> >>>
>>>>> >>> [1] https://dev.openwrt.org/ticket/7209
>>>>> >>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_=
pci_id.patch
>>>>> >>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361=
p.patch
>>>>> >>
>>>>> >> I doubt that [3] is really all that's needed to make it work. =
=C2=A0But if
>>>>> >> there's someone for whom it works, I'd like them to run some t=
ests on
>>>>> >> mwl8k + [3] on 88w8361p.
>>>>> >
>>>>> > Just asked lautriv to do so (he will do against linux-3.3.3), l=
ets' see.
>>>>> > Also, I refreshed and adapted a bit the instructions (see attac=
hment).
>>>>> >
>>>>> > - Sedat -
>>>>>
>>>>> [ CC Jim Cromie ]
>>>>>
>>>>> Now, with extracted firmware files renamed & copied to
>>>>> /lib/firmware/mwl8k/ and applied patch (see attachment) against
>>>>> Linux-3.4-rc4+ I am seeing with modinfo:
>>>>>
>>>>> $ sudo modinfo mwl8k
>>>>> filename:
>>>>> /lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8=
k.ko
>>>>> license: =C2=A0 =C2=A0 =C2=A0 =C2=A0GPL
>>>>> author: =C2=A0 =C2=A0 =C2=A0 =C2=A0 Lennert Buytenhek <buytenh@ma=
rvell.com>
>>>>> version: =C2=A0 =C2=A0 =C2=A0 =C2=A00.13
>>>>> description: =C2=A0 =C2=A0Marvell TOPDOG(R) 802.11 Wireless Netwo=
rk Driver
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366_ap-2.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8366.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8366.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8687.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8687.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8363.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8363.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/fmimage_8361p.fw
>>>>> firmware: =C2=A0 =C2=A0 =C2=A0 mwl8k/helper_8361p.fw
>>>>> srcversion: =C2=A0 =C2=A0 9E1479A05C8D67E6AE90746
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A43sv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A40sv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A30sv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A2Bsv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A24sv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Csv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A0Asv=
*sd*bc*sc*i*
>>>>> alias: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci:v000011ABd00002A02sv=
*sd*bc*sc*i* <--- 8361P:
>>>>> 0x2a02 PCI device-id
>>>>> depends: =C2=A0 =C2=A0 =C2=A0 =C2=A0mac80211,cfg80211
>>>>> vermagic: =C2=A0 =C2=A0 =C2=A0 3.4.0-rc4-5-generic SMP mod_unload=
 modversions
>>>>> parm: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ap_mode_default:Set to 1=
 to make ap mode the default
>>>>> instead of sta mode (bool)
>>>>>
>>>>> $ ls -l /lib/firmware/mwl8k/
>>>>> insgesamt 456
>>>>> -rw-r--r-- 1 root root =C2=A075848 Apr 27 13:49 fmimage_8361p.fw =
<---
>>>>> 8361P: Firmware image
>>>>> -rw-r--r-- 1 root root 101780 M=C3=A4r 19 19:32 fmimage_8366_ap-1=
=2Efw
>>>>> -rw-r--r-- 1 root root 101976 M=C3=A4r 19 19:32 fmimage_8366_ap-2=
=2Efw
>>>>> -rw-r--r-- 1 root root =C2=A096664 M=C3=A4r 19 19:32 fmimage_8366=
=2Efw
>>>>> -rw-r--r-- 1 root root =C2=A073252 Feb 23 20:07 fmimage_8687.fw
>>>>> -rw-r--r-- 1 root root =C2=A0 2476 Apr 27 13:49 helper_8361p.fw <=
--- 8361P:
>>>>> Helper image
>>>>> -rw-r--r-- 1 root root =C2=A0 2476 M=C3=A4r 19 19:32 helper_8366.=
fw
>>>>> -rw-r--r-- 1 root root =C2=A0 2476 Feb 23 20:07 helper_8687.fw
>>>>>
>>>>> As said... ***compile-tested*** only here.
>>>>
>>>> Which doesn't say much at all, but..
>>>>
>>>
>>> As already pointed out, no Marwell WLAN hardware here. Marvell comi=
cs
>>> of course :-).
>>>
>>>>
>>>>> I had a short query with lautriv on #linux-wireless this afternoo=
n:
>>>>> * mwl8k kernel-module was autoloaded
>>>>> * wlan0 interface got fired up
>>>>> * ESSID was accepted
>>>>> * logs reported 802.11bgn support is active
>>>>> * (he tested on Linux-3.3.3)
>>>>>
>>>>> With WPA/WPA2 lautriv had some problems as his installation was
>>>>> missing wpasupplicant.
>>>>> He setup a classic /etc/network/interfaces.
>>>>> After resetting his router mwl8k worked nicely.
>>>>>
>>>>> Unfortunately, he was on the run and promised me to send logs and=
 do
>>>>> more testing this evening.
>>>>
>>>> ..but this is pretty interesting. =C2=A0I thought that the only av=
ailable
>>>> 8361p firmware used an incompatible firmware API, and I didn't kno=
w
>>>> of the existence of an apparently compatible firmware.
>>>>
>>>>
>>>>> So, Lennert if you want more testing - What? How? etc.
>>>>
>>>> For one, the output of 'iw phy', please.
>>>>
>>>> Also, does monitor mode work? =C2=A0Do you get plausible channel/r=
xpower
>>>> values in tcpdump in monitor mode?
>>>>
>>>> Are there any messages in the syslog about failing commands?
>>>>
>>>>
>>>> thanks,
>>>> Lennert
>>>
>>> On 1st sight, logs look fine:
>>>
>>> [21:52:52] <lautriv> [ =C2=A0 =C2=A06.050967] ieee80211 phy0: 88w83=
61p v4,
>>> 00173f3bdde3, STA firmware 2.1.4.25
>>>
>>> But WLAN connection is not that fast and stable as lautriv reports
>>> (several abnormalities were observed).
>>>
>>> I requested a tarball which includes:
>>> * dmesg (Linux-3.3.3)
>>> * e_n_a (/etc/network/interfaces)
>>> * ifconfig output
>>> * iwconfig output
>>> * iw_phy output
>>> * ps_axu (WPA) output
>>>
>>> lautriv will be so kind to be around on #linux-wireless/Freenode th=
e
>>> next days (UTC+2: German/Swiss local-time).
>>> Just ping him.
>>>
>>> Hope you have fun, together!
>>>
>>> - Sedat -
>>
>> A new tarball from lautriv with same outputs as before, but now test=
ed
>> with Linux-3.4-rc4.
>>
>> - Sedat -
>
>
> heres my logs, using firmware extracted by Sedat's script,
> and the patch on mwl8k.c
>
> bottom-line, it appears to be working.
>
> its contents are a bit more pedantic, and includes data for
> another wifi card (rtl8180 based) also in the box.
> It was obtained by this script:
>
> #!/bin/bash
>
> # dmesg (Linux-3.3.3)
> # e_n_a (/etc/network/interfaces)
> # ifconfig output
> # iwconfig output
> # iw_phy output
> # ps_axu (WPA) output
>
> devs=3D"wlan0 wlan1"
> apmac=3D00:14:d1:e8:65:0a
>
> loudly () {
> =C2=A0 =C2=A0echo "# $@"
> =C2=A0 =C2=A0fname=3D`echo $@ | sed -e 's/ /-/g'`
> =C2=A0 =C2=A0$@ 2> $fname-err | tee $fname
> =C2=A0 =C2=A0[ $? !=3D 0 ] && echo non-zero exit on $fname: $?
> =C2=A0 =C2=A0[ -s $fname-err ] || rm $fname-err
> }
>
> ( iw --debug event -f > iw-event-f )&
> pid_event=3D$!
>
> for N in 0 1 ; do
> =C2=A0 =C2=A0loudly iw dev wlan$N interface add fish$N type monitor #=
 flags none
> =C2=A0 =C2=A0loudly iw dev fish$N set channel 8
> =C2=A0 =C2=A0loudly ifconfig fish$N up
> =C2=A0 =C2=A0( tcpdump -i fish$N -s 65000 -p -U -w =C2=A0fish$N.dump =
)&
> =C2=A0 =C2=A0pid_dump_fish$N=3D$!
> done
>
> loudly iw list
>
> #loudly iwspy
> # gives: Interface doesn't support wireless statistic collection
>
> for dev in $devs ; do
> =C2=A0 =C2=A0loudly ifconfig $dev
> =C2=A0 =C2=A0loudly iwconfig $dev
> =C2=A0 =C2=A0loudly iwlist $dev scan
> =C2=A0 =C2=A0loudly iw dev $dev info
> =C2=A0 =C2=A0loudly iw dev $dev link
> =C2=A0 =C2=A0loudly iw dev $dev scan
> =C2=A0 =C2=A0loudly iw dev $dev survey dump
> done
>
> for phy in $phys ; do
> =C2=A0 =C2=A0loudly iw phy $phy info
> done
>
> # these are unsupported on wlan0
> loudly iw dev wlan1 survey dump
> loudly iw dev wlan1 station dump
> loudly iw dev wlan1 station get $apmac
>
>
> for N in 0 1 ; do
> =C2=A0 =C2=A0loudly iw dev fish$N del
> done
>
> kill $pid_dump_fish0 $pid_dump_fish0
> kill $pid_event
>
> dmesg > dmesg
>
> grep -vE '^#|key' /etc/network/interfaces > e_n_a
>
> exit

Hi Jim,

thanks for your testing and the nice testcase-script!

lautriv you wanna run some more tests with Jim's script?

Jim, how stable/fast/reliable is your WLAN connection?
Suspend/resume tested?

Hope this helps to get native Linux support for 8361p.

Regards,
- Sedat -

P.S.: BTW, only to clarify it should be "e_n_i" as short-form for
/etc/network/interfaces file, but e_n_a sounds more female and nicer
:-).
