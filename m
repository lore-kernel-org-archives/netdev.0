From: Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Sat, 28 Apr 2012 16:36:21 -0600
Message-ID: <CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com>
References: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
 <20120427094007.GU3157@wantstofly.org> <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
 <20120427094637.GV3157@wantstofly.org> <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org> <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org> <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org> <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e89a8f234567783ff104bec4db4b
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lautriv <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--e89a8f234567783ff104bec4db4b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

[dropped lkml from cc]

On Sat, Apr 28, 2012 at 4:25 PM, Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> w=
rote:
> On Fri, Apr 27, 2012 at 11:53 PM, Sedat Dilek
> <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
>> On Fri, Apr 27, 2012 at 8:58 PM, Lennert Buytenhek
>> <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org> wrote:
>>> On Fri, Apr 27, 2012 at 03:29:26PM +0200, Sedat Dilek wrote:
>>>
>>>> >>> >> >> >> Are you planning to or even working on support (for) 8361=
 devices?
>>>> >>> >> >> >
>>>> >>> >> >> > I don't have any such plans, and I don't know of anyone wh=
o does.
>>>> >>> >> >>
>>>> >>> >> >> Does 8361 require firmware support?
>>>> >>> >> >
>>>> >>> >> > What do you mean by that?
>>>> >>> >>
>>>> >>> >> IIRC ath5k for example needs no external firmware file.
>>>> >>> >
>>>> >>> > The 8361 requires firmware to be loaded into it before it'll do
>>>> >>> > anything useful.
>>>> >>> >
>>>> >>> >
>>>> >>> >> >> Does a firmware file exist (name?)?
>>>> >>> >> >
>>>> >>> >> > There's firmware for the 8361 out there, however, that versio=
n of
>>>> >>> >> > the firmware implements a firmware API that is different from=
 the
>>>> >>> >> > one that mwl8k currently implements.
>>>> >>> >> >
>>>> >>> >> > You could add 8361 support to mwl8k, but then you'd have to g=
o over
>>>> >>> >> > all the firmware command invocations in mwl8k and make sure t=
hat they
>>>> >>> >> > will work on the 8361 firmware that you're trying to support =
as well.
>>>> >>> >>
>>>> >>> >> Without having a 8361 this will be even harder to walk through.
>>>> >>> >>
>>>> >>> >> Anyway, thanks for your detailed explanations.
>>>> >>> >>
>>>> >>> >> What's the alternative for such affected users?
>>>> >>> >> Use ndis-wrapper?
>>>> >>> >
>>>> >>> > I'm not sure. =A0I've never tried to get a 8361 work under Linux=
.
>>>> >>>
>>>> >>> Just found on [1] this same wrong patch in [2] :-).
>>>> >>> Dunno if [3] worked and from where they have stolen fw-files.
>>>> >>>
>>>> >>> - Sedat -
>>>> >>>
>>>> >>> [1] https://dev.openwrt.org/ticket/7209
>>>> >>> [2] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_fix_pci_i=
d.patch
>>>> >>> [3] https://dev.openwrt.org/attachment/ticket/7209/mwl8k_8361p.pat=
ch
>>>> >>
>>>> >> I doubt that [3] is really all that's needed to make it work. =A0Bu=
t if
>>>> >> there's someone for whom it works, I'd like them to run some tests =
on
>>>> >> mwl8k + [3] on 88w8361p.
>>>> >
>>>> > Just asked lautriv to do so (he will do against linux-3.3.3), lets' =
see.
>>>> > Also, I refreshed and adapted a bit the instructions (see attachment=
).
>>>> >
>>>> > - Sedat -
>>>>
>>>> [ CC Jim Cromie ]
>>>>
>>>> Now, with extracted firmware files renamed & copied to
>>>> /lib/firmware/mwl8k/ and applied patch (see attachment) against
>>>> Linux-3.4-rc4+ I am seeing with modinfo:
>>>>
>>>> $ sudo modinfo mwl8k
>>>> filename:
>>>> /lib/modules/3.4.0-rc4-5-generic/kernel/drivers/net/wireless/mwl8k.ko
>>>> license: =A0 =A0 =A0 =A0GPL
>>>> author: =A0 =A0 =A0 =A0 Lennert Buytenhek <buytenh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>>>> version: =A0 =A0 =A0 =A00.13
>>>> description: =A0 =A0Marvell TOPDOG(R) 802.11 Wireless Network Driver
>>>> firmware: =A0 =A0 =A0 mwl8k/fmimage_8366_ap-2.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/fmimage_8366.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/helper_8366.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/fmimage_8687.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/helper_8687.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/fmimage_8363.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/helper_8363.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/fmimage_8361p.fw
>>>> firmware: =A0 =A0 =A0 mwl8k/helper_8361p.fw
>>>> srcversion: =A0 =A0 9E1479A05C8D67E6AE90746
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A43sv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A40sv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A30sv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A2Bsv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A24sv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A0Csv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A0Asv*sd*bc*sc*i*
>>>> alias: =A0 =A0 =A0 =A0 =A0pci:v000011ABd00002A02sv*sd*bc*sc*i* <--- 83=
61P:
>>>> 0x2a02 PCI device-id
>>>> depends: =A0 =A0 =A0 =A0mac80211,cfg80211
>>>> vermagic: =A0 =A0 =A0 3.4.0-rc4-5-generic SMP mod_unload modversions
>>>> parm: =A0 =A0 =A0 =A0 =A0 ap_mode_default:Set to 1 to make ap mode the=
 default
>>>> instead of sta mode (bool)
>>>>
>>>> $ ls -l /lib/firmware/mwl8k/
>>>> insgesamt 456
>>>> -rw-r--r-- 1 root root =A075848 Apr 27 13:49 fmimage_8361p.fw <---
>>>> 8361P: Firmware image
>>>> -rw-r--r-- 1 root root 101780 M=E4r 19 19:32 fmimage_8366_ap-1.fw
>>>> -rw-r--r-- 1 root root 101976 M=E4r 19 19:32 fmimage_8366_ap-2.fw
>>>> -rw-r--r-- 1 root root =A096664 M=E4r 19 19:32 fmimage_8366.fw
>>>> -rw-r--r-- 1 root root =A073252 Feb 23 20:07 fmimage_8687.fw
>>>> -rw-r--r-- 1 root root =A0 2476 Apr 27 13:49 helper_8361p.fw <--- 8361=
P:
>>>> Helper image
>>>> -rw-r--r-- 1 root root =A0 2476 M=E4r 19 19:32 helper_8366.fw
>>>> -rw-r--r-- 1 root root =A0 2476 Feb 23 20:07 helper_8687.fw
>>>>
>>>> As said... ***compile-tested*** only here.
>>>
>>> Which doesn't say much at all, but..
>>>
>>
>> As already pointed out, no Marwell WLAN hardware here. Marvell comics
>> of course :-).
>>
>>>
>>>> I had a short query with lautriv on #linux-wireless this afternoon:
>>>> * mwl8k kernel-module was autoloaded
>>>> * wlan0 interface got fired up
>>>> * ESSID was accepted
>>>> * logs reported 802.11bgn support is active
>>>> * (he tested on Linux-3.3.3)
>>>>
>>>> With WPA/WPA2 lautriv had some problems as his installation was
>>>> missing wpasupplicant.
>>>> He setup a classic /etc/network/interfaces.
>>>> After resetting his router mwl8k worked nicely.
>>>>
>>>> Unfortunately, he was on the run and promised me to send logs and do
>>>> more testing this evening.
>>>
>>> ..but this is pretty interesting. =A0I thought that the only available
>>> 8361p firmware used an incompatible firmware API, and I didn't know
>>> of the existence of an apparently compatible firmware.
>>>
>>>
>>>> So, Lennert if you want more testing - What? How? etc.
>>>
>>> For one, the output of 'iw phy', please.
>>>
>>> Also, does monitor mode work? =A0Do you get plausible channel/rxpower
>>> values in tcpdump in monitor mode?
>>>
>>> Are there any messages in the syslog about failing commands?
>>>
>>>
>>> thanks,
>>> Lennert
>>
>> On 1st sight, logs look fine:
>>
>> [21:52:52] <lautriv> [ =A0 =A06.050967] ieee80211 phy0: 88w8361p v4,
>> 00173f3bdde3, STA firmware 2.1.4.25
>>
>> But WLAN connection is not that fast and stable as lautriv reports
>> (several abnormalities were observed).
>>
>> I requested a tarball which includes:
>> * dmesg (Linux-3.3.3)
>> * e_n_a (/etc/network/interfaces)
>> * ifconfig output
>> * iwconfig output
>> * iw_phy output
>> * ps_axu (WPA) output
>>
>> lautriv will be so kind to be around on #linux-wireless/Freenode the
>> next days (UTC+2: German/Swiss local-time).
>> Just ping him.
>>
>> Hope you have fun, together!
>>
>> - Sedat -
>
> A new tarball from lautriv with same outputs as before, but now tested
> with Linux-3.4-rc4.
>
> - Sedat -


heres my logs, using firmware extracted by Sedat's script,
and the patch on mwl8k.c

bottom-line, it appears to be working.

its contents are a bit more pedantic, and includes data for
another wifi card (rtl8180 based) also in the box.
It was obtained by this script:

#!/bin/bash

# dmesg (Linux-3.3.3)
# e_n_a (/etc/network/interfaces)
# ifconfig output
# iwconfig output
# iw_phy output
# ps_axu (WPA) output

devs=3D"wlan0 wlan1"
apmac=3D00:14:d1:e8:65:0a

loudly () {
    echo "# $@"
    fname=3D`echo $@ | sed -e 's/ /-/g'`
    $@ 2> $fname-err | tee $fname
    [ $? !=3D 0 ] && echo non-zero exit on $fname: $?
    [ -s $fname-err ] || rm $fname-err
}

( iw --debug event -f > iw-event-f )&
pid_event=3D$!

for N in 0 1 ; do
    loudly iw dev wlan$N interface add fish$N type monitor # flags none
    loudly iw dev fish$N set channel 8
    loudly ifconfig fish$N up
    ( tcpdump -i fish$N -s 65000 -p -U -w  fish$N.dump )&
    pid_dump_fish$N=3D$!
done

loudly iw list

#loudly iwspy=09
# gives: Interface doesn't support wireless statistic collection

for dev in $devs ; do
    loudly ifconfig $dev
    loudly iwconfig $dev
    loudly iwlist $dev scan
    loudly iw dev $dev info
    loudly iw dev $dev link
    loudly iw dev $dev scan
    loudly iw dev $dev survey dump
done

for phy in $phys ; do
    loudly iw phy $phy info
done

# these are unsupported on wlan0
loudly iw dev wlan1 survey dump
loudly iw dev wlan1 station dump
loudly iw dev wlan1 station get $apmac


for N in 0 1 ; do
    loudly iw dev fish$N del
done

kill $pid_dump_fish0 $pid_dump_fish0
kill $pid_event

dmesg > dmesg

grep -vE '^#|key' /etc/network/interfaces > e_n_a

exit

--e89a8f234567783ff104bec4db4b
Content-Type: application/x-gzip; name="mwl8k-8361p-logs.tgz"
Content-Disposition: attachment; filename="mwl8k-8361p-logs.tgz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h1l8wvk91

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
qDCNIQogGVJ7e7tpLDG0dj58pcdSTlnLGatpGjGcZljObLHyNgqOrKZ5RCExCPdHBlMxUYjzKNks
TlMhUt+1ipIjlTBo58k/gLY+vTZOMNKpauv63ocp3eHtvWur34zj8oNXvw5w94YK0jEOYkjUOAqg
/PerCnTGseWht3s8bnzjCHTc8/DbPwvj2D7487NAWxNH6GcIOqceTm1Q2B2uOpwd43h/J3cGwH3o
67SiMZPGOApxz/H3Qp1x3HjWOz0eN75xrOu4gnznZ2Ecd46q+wS0ZX9wcJwhuKqt23ofgneHD/au
rX4zjpLdS9cC3MecaYXapMY4BkP51zYZibFI/liNccw58G6Pxy10qsz27N2z5vRriLPOeW1dQd1L
hrOdmCB4lfmeAxsuWfabi7z31F5etXvU71d+wp/SFVxbMGzM+V9sO+r78uOja7eYN9juO1HyxP5X
bl8yr3HCnievZb5aeUHTjQ9d96kjcN/BEcf+3jj66aIPF/943rKDS+ZdvX/GKPubywo67y/zH5xl
LFr+zeKtp/26bOeaZeP/a/gE45Izxs9z/2vN4CsXLfmqhPxm09NzW/4874HdZ1WPb13TetmrxY9/
fBpd8Lb9kt3B8etPbL7jyYq1Z7za/shH/5h825EfDlV9t+vYZTse5Wd17b//qYWOo7VP3ndm5cOn
77nxmNW0cMh65n/zmpz5rSsfHvfwTcusq0uvPVC3Zusm68Tx/3ikGHR25zYjYUX6smp0tvKwTmfT
4ulsKdKZCxM0f3CD+5tX33xs0qNH6m5/ad+pNdXfvmUf+9+j14U/Om3DwidHP/LUWQ0lF9i3Hhj7
3taX6+puay0o3vvZti+XLLju1N8b97Vc89n374wcWz/8kz/du/Tro1RNGxH8j3G3CZfklTQMOTR+
0davH3vlwW/HDTNeVvtj9TUv3/zS5/++Zull975+9TmzpNCt5ebpf5n6yJbr25qGXbTjupbR4+5s
uXlMyf+w38+cdEP+e1vv52/deQX1zG/GbP+0dIT45ZW7blr7fEH1gj8NXT3zg1c6nv6BWpbnv+Xc
VeRYz7vNt+SdeJWbuODI+B1dE+/j5gTPnH33ec9y//c299u1j9w0tt70Q/HTD34ulf7bpADzq3tz
t3zw7fQfXnz6L6DGIZY4L8iWvpfa7NHJsPBedlqaxXD3WBxSvBRn5vP4kdRmj06GTxzJDtxJF+/f
A3CN8+O8IFv1fmqzRyfDq9/P0kuGnD9+MB9Gww/oh3adpg9Tmz06GS7+MDtwv668/VKAO/QuA7EE
lV+i6QJO/qjCvUsHV+4C5N/hl/5Q/J+f/VmGm0cULZe83g5HC+SklkGj8bg311Ckgh5UaRiUaAQ/
hGDy0DMuLR/VNXI00kq8nykjioh/iXN91rBTCSMxybCfOJXIJ04nrjQYdE89mDCNzMk9nkcQR89I
PD8whFA1ukqv0TOJdbPZxOiOjkL3ufgI12yaexy0vfZlQzpOjtI4OSOU33jIoIuA5s+W6yBaW/Ej
oOMd6ycf/VlEQM9fvPx3oK0uVv/yd+F2VVvre58ZPRn+J3tXAhZV1f5nAxQBoUzzM+2SZpoy3Hvn
zp0lIRY3FAQRU3GBEQYc2YYZwC0F/pqtJra4Zt9FKvcE/epTy0TTtNKCMj8zURSXLCzQ0lz533NB
HeZcxnOb6X59wn0elQfm5feb933Pe867nLHYsbZcl1i/EDQP0L3ZRw4txZ8XHm9aijBd26VYund+
8dG2pYiwFK/9eP15oO3nguVClmKIzVLsAOQ7Rskle1iqe2ystXDXUTvnuluatbVW+d783SjWEtdO
M+2WdijrKnfWd4eZ8g9PhH/825sHNvou7zJQya5vt3CTNSmLXcnekabMNOsMKzYI/H9/7Hr2yCOU
uBJXsStZRpF2i9fu1WAFz/sv+4Rp89otwKa/bFVAK/Ad/FiTTUscrsCKvW8Sx9pWIIK2b6499TDQ
9n+GukPaXl1e1aRt+KRkq+3qvUt2VbVpG0Hb+yfuXAK0/WMNXEgcZzjeorabVdZuMSNPibMZSmcF
PwPoHrTylLaqa9AmoW4xJ2vEobttTk4eoLtVzjP8Yj6DNgl1i8k+Iw5dfFTPY2NYujM+k7bQTJXy
NVNjvIDQs+zh1b5zK51V29S5vf0em3dugdz4A7Dce/m1drqB5c6zciT7TdKGZNMOzW6qEMlEr9uq
47Zp8BtCjsDH5Y1z7ZH5j8vMzLfm1baK43KeV/YRoK3ji+Dj8uaQC2jV5FtM6AVxfLjv2fGvAroZ
/nDbrKziF7QRo1vFlb+IQzfM1LES0J1VxjMrmViHViRqYAx14tD9/FDv9wHdAWE8UyV19WhFogam
vl4cukSFJRjQrajkmZUsuIRWJGooLrwk0pzvu19fB3TzDDzbhe/vaEWiBsbvd3HoXl4TuBDQnVkP
Fzg/YC6jjdQ3vFN8WaTNuI/PakB30DQvIaNCZm53o6Z7QbvUvn5XHM4lAblv8wWNkhTY5JFSIF90
WdAoSZGNvGwsK7/yvASavpH8cA1t+uYtOvYDB9M3UtdO3ww6fCYJUI7qJ6gKxti8ZTmQf3SVTNBU
lo28AshruioETWXZyLsB+biVCshVJO232U3vcK7SI/nhfqUnNpdnA7maVbDcbp97y3l2hI/uV/O2
I00LMQ2MVBIsyvJ7YNo0BtAd9k+eraNIGow0ftPALJKKQ/cna08c0B0YyNMnxeRIdMsbGH+5OHT/
WHfuGKA7YSfP1lGqCEaZFqpoYMoU4tDdHps2B9CN3S2orVths9bcgfzQo56SSvallTZvV/2Fg7fb
++L+3yIb/8bkc0NL3n9E2lQk8AtNN5syjbFGa5YlZ4glK9dsWypwd1PI5OCtKwKlinuVChpzemmd
5M/n9J6J+/K5YHLdEwoKnVIbad99g3BQWK3xEjSCaDtpw+0bYV5QbrTkvXeacB1P2pTO6ku4O/Sj
+yU3ituaFAS0NSIa7pn6/NteW/yrrrqBCXWsLdcdhzP/9Qqg++L7gg4ldbaTNkA+d4c35BwX13kE
oyTOFbNOrfdoFc7h0evTmdxSqoHv5vx+yF5b/M5R13DmO8facplzDKIMEYBu2iEfqO764852wS0N
BjWru+5bWKk421Z3bXwc1V1fXj7nOtD26d4dBU1EetvMNY0D99RkEqjPVBvkdvZSM2vFtOPrM9Xt
OxrshmCttj6TOD6Rt2z728CmXR6AbTosCtWmuhFtNv372PShzRN+ADZN94dtumYCqk2XTGyz6d/H
ppMWDf0c2FSyA773YpJ6nEXpmflKius9xdnYpw70PgDoXouE772UFnghnUMwCVPoJQ5d75QTT3J0
j8EF/M2+Pkh0cckqPx9x6NbE/7EX0H3iGzfo2FTfcJuu40k5fP8yvw5txyaEpTftkY3c0ns0A655
mco6nG0+6cbvHCESprijOM5x7qPoZwDdMS+5C7raYHPK8wTy/SZ7QM51bqFvMMrsV8j+RcVebc6F
4Fxdn/92PtB2vUzQRRTMxlodgPwcv3bQXr810vssyuxXzP41Ud5te/3fZq/fXD1sFbBpQ307aAW+
ifucRZn9Stz/HOHTtgIRtF3/ypB0LgPqDncUpxp8kU5WZgkzspM44T2a6ZMK6F7fAJf/NlU/hHRU
KZAwJx8Sh+6VdycPAXQvDeC5MmHugkS3SMJkdxGHbuyJ+K/iWbo7XuK5MiHpikSXkTDSruLQnWI9
WQrobs+Hr0x8/+ttumscRory/fOlndsiRdPjKFLoF6/fBrT9fbwcute3rqpLU6S4rW3+O2rV+6X+
adwL+vTQdy5768mZj2eQ7/9cWVDy5YmlUbXDTo+1VB1Wlv6+s31D2pzn+o+sqVn4lTXs6ZxtOy/O
v/HBWX9l++jXuz895b3IYWMW7onI3UAERV635MfEHEkykHNSv8uKSV26Z9m2tWfc3TqtJ6eX9Hjs
8IUzn4TGZi/rPndY53KVD/bYwYShHsvmptUEpe7Bnj+nK3tgw+SPQwa3yx7yat+lF57f9EJth9in
wns87hZZklQSnLC2xzu+3rcePFzqt6DHkbiVA0+e80sr/EYWsf6fij3rNp2JDRt7/Xy8ZVC6tnyY
6pL6SqrHgoqDq3vdGlOYeOnS20WdFscFZh0DOrs2w13IeB/uDYRenukONaLy3Lo1KrqF8T4gR+TD
ct08u9mFclhuJysnYLwvxLvZeB/4DRdfhD9JIM3LHpm/S1H97MobPVpFl+JC/JWXgLZ6j4JvT/sf
fgTSFusgR8+Hr5zbbABtduxnWKvQ1vycLQeBtjbFwwNlWSfttVUg4e3pSJhKx9py3WeInPhMDehu
/AkeYihNfAxpC5VIGcNj4tB96Vzcs4Du0pk8N2breiLR9ZUy9T3FoWupkdQCutLdHaClo6V6Qe1Q
vqUTMruPulerWDr+QVW9gLbm+sCTBeUFaNqKmV1a2Dq0tWhFGhdoOu+EtdWReBxJW4mzG5peeb9r
q3p9Q29uy/fk+RjMAntt8QcOTMoUOtaWywKH70njIUC3dDmciJX5PoFW4pYyfk+IQ/eDFRMnAron
AjtCvthllT1dfl8smu1R4pju/eKLL3h6h45ntaU7z5O2Mn2QjBsiZYr7iGPchzMvHQN0jdPh6x1l
+JNIdGOkDPGkOHR3dPpyNKAb3o7no7DL+yHRTZQyu/qJQzftmemfALrjlvJc74gJQKJrljIjA8Sh
e2pWYCdAtz7dXWJiAU02dL/trbSjG3KX7sNRvbZca/waZ3Gl7UAS1p+lR7pzc99Fcqki4B+TvSQg
1efCB/vYjI9nja8+A4Cf6cMzHFxtD8yvpwIpc1Ipjp4OfPfN44BuvzEekJ76+AUi6SmkBT25OdLT
u1U/lgHgVaHtIOAl19GAY1oAdncEXLV+0xsAOGw4nCZub7AH5pJqDrJZ4jN7nQRvFXvAtBcv+gBt
qbby3Dsy42iVVimT7VhbLnPnjZ5nBwK65/u1h7zq+Bl7uvxeldiCV3k48qp5o9ptAMAybXvIq8bX
2gPze5XvnOEXWodXvRPosQ1oq6CzJ2SmuAoCyUzmFszUzpGZFv7fTTMA1jzhCZkp4Qd7YH4zYXOi
jxGtwkzdX/H5Gmjr6hPw6P6I0/ba4iqfnIYeTXjmJJBLH8pzhUNCovU7pIyUFGnwJaE2AdCddwQu
1pQVqdDu80iZRSpx6HYbv5WzStIUOEXcgqnR7vNIS/zVIh0ct3y0dTz3oZZwiuhRRiPRrZBebnrl
Xz/okq8/MoGl6zZZAoWm0EkapNBU0EJoau8oNCVdXX8TAG8fzPMZ1CFaJD1VS5lQrTh6+tfOtzsD
uvOipJCeqiLs6fLrqagFPXk60lO3hbWcgbqOgz/zYH20PTB/CC+YsyLGsZ7ulxBOm1cOANqa8bQM
MtPGp3RIZmJaMFMHR2YKmza8GgBPi5ZBe0fPKHtgsHc0NjSV77Y7DeS6HebJ4ivs5fiXQZ2UqdSJ
swwiP/piPqD7YApPFp/4FFpfQsYYnhKH7lgFrgR0h1/myeLrBqD1JWRM/QBx6P7jxsevALpR83mS
6YJgtGqojCkMFodu3NoPl3ChqTPPTVvfELRqqIzxCxGHbpeyXzMA3Ufeg49pZUwoWn1PVlwcKg7d
iXTdYEC3M83zsa54OFp9T8YQ4eLQvZme7wfohqd6S9JYwDQbuouTBkKR984sgM1uVS69Q9E+/DqK
vaPfWLAOQM9lT4j2sfdiij00d27nQEsejPcHcj658K3I41Pt5fi3Vkn+V2kDW8XW+uGV4buBtmbm
wlo+aOXV8p3sCMhN/YynxVNuL8fvx4kyZpdjLbvMjxd902n/RJbulw/CXYCymMFohV8ZM3KwOHSp
Nf1DAd3p6+FjdPsfh6DVX2VXm1751zfQls9JAXT3qXiutJgj0OprMiY7QqQYrPx1AaD7zac8xx3J
cLTMXsZIh4tD98FZZxYDut3j4EsWpUWRaJm9rHhRpEjnh5LjPwG6lTU8xx1sBFpmL2P8R4hDNzx+
4xFAd3MOz0xOaTRaZi9jyqLFofvRpKtDAd1Dcp6ZnJCRaAm2jAkdKQ7d3/Y9GQvofv46fNwprYhF
S4RkTGWsOHSXT/n8W067PXlGshPj0BIhOWOIE4fuDQ9q2yTwsS3ZPL3tutFoiZCcqR8tDl2FPLEv
oPualCcrLhiDlgjJiwvHiHSdIK+qFtA9N0cOVR3eaxiLVHXAZH+iqzh0xc2PAfCiRTzbqe84tAxM
zviNE0dPK76rOQ7oDjApID3Jf7Kny68nvAU9OWyC4he2LwPAr+Yo4A8O/dUeuIUmaP7bdY71dL+c
9HO6vpYFtLVrPvy5ZvHt4/lO+h1TpvYufcj9tWQg94o/XG0pZezl+L0xRM4Ux4vjjWHf39ADui+M
coO8cewhe7r83hjSgjc6bJ5eS9t8EAA/n+gGeePqH+yBW2ieFiw95lhP94s39vVL2AG05RYMj7Z8
9sl4tMmJFszksHlav32IHwBWRsDXEdZ/ag/cQvO0YMWe8a3CTFdDNZFAW/si4Gsjyw/Ya6t5eQDI
fVLG8x8i4hPQylzyYmKCOEHjq0OPjAB0mVB4QGRL+US0aoa8ZNdEceiOqij9FNB9o5InZ4lJQKtm
yJmRCeLQ3XoAuwjoZhjgnGVLdSJaNUO+6mSiOHS1wXsXALpVX3aAQlNppAFt/KaF0OSwebomrJo7
H796BL7AUDrKHpg/NJkLmDhDqwhN9VeObgDaCv/QCzJTB81ktPGbFszksHdbQa32AsAv1/PktGZ7
YH53LpIz2ZPFcefDslOTAd1ixhvSU6p/EtosQAt6ctg8HRBdXwiAFxTCyfRmSTJamU1eLE0WR09l
GD4vAXw4yNc8yXSREa3MJmcWGUXq2Sq+/QLQNSTwJNNYKlqZTc74p4pDd1JVl96A7uxfeXLa0ilo
ZTY5UzZFHLoDXx60G9DV5fO0mEOmopXZ5EzoVHHofv3v5Tig27cjT821Ig2tzCZnKtPEoavZ8hUD
6HZfBR+3SpIy0MpsiteSM0TS7ut/PAXoBi5sDzVBR8ZmIjVBGdmfaoIOrDt1HEAnFrWHzt8bR9tD
N2+CArnTy+FJ3g1j7OVaaIIWvjU2s1UcJeInPZYOtBW1AtbyikReLd/JcoBcbSDP7EGdvRy/H/sq
iusda9llfrzs2KYMQPfpnfA5fHOBGa3+qiguNIvU9+q/9m1ANyiap8Xsa0ErgyoYP4s4dLfk9f4c
0H3xBM8tQsaKVidTMMVWkXoHla8OSGTpdgjgmdTEc9EydAVD5IpDN/fG94sB3c07eI475XloGbqC
2ZUnDl31Q1XpgK4siqfFHDMdLUNXMCOni0P39OK4Ao5uFc9xp3oGWoauYE7OEIfuhNd7MICudwbP
ccc8Cy0DUzDZs8She/V8776A7s0bPNePJLPREiEFI50tUj/n53A/Set6Mqala9MCtCqaMAekZ6Va
A03TApKNeQHT0g2ZRIApM8doSTEkGQMMyckBKSbrFCIgZ4bZGJCRlWliTyhoGDj70BQF/iU0atz2
39uPhCA0lAanaTVJSnCSVNNqCYb/tW+98cm15hgsGCaZaspIcvS6e/38f/Rpyf7A1niA1ZgTkDTF
kJlpTA/Q/mkMYfYnJDhBa9SaNvuL8cD2T2HzjxRTamMEcAnGveyvoYi79lex659Q4ypVm/3FeDgr
Y+ABH3mKGTOTDGb9oJwpRkumMQfDho5hA78Fw3E9odVTyXqS0k9W6VMMGOaJ3XlM4KXgdXpCRyoJ
WqskcCVBqDEsLMlgzbH9LqlmvxtlsKbp2a+Ut//gdr+MbvxtWIpRi+v1JAedkqJPMXLwKYZAmsJG
JWWZjXpA2kZ4dAwWFhsdOjA8dFQcFjt6xIiIEUOwqNGRcRHcd7CouNF61rlw9itjjsWUpCdshGPH
YmZDUpoxx6onMaPFkmWx6nEs2ZJlNhuT2a+y8thv5maCb6ZYDBlGvS3tuLvC2nsIJxksFpPR0kw8
KSs93WQ1ZXEvyJmenWvMNaYbM/UEuzyw5hwnz8gxWvUEocWxPoSSwIabwvpy+E0/UBEk+AHJ/cDT
8x72v9f+n5IVwBJ3zsfuGf/VtM36V4P4T9Bt61+UZ7DBlG5MxnKyMIvRkIwlpRusVlMylsJ+V49F
T55qTMrBMrNysJSs3MzkezlT2/M/90DrnzvkK5NzM8zKHOP0HFdgcOufbmn9UypKo7m7/nEK7P8k
TretfzEeDAO7P65stAUWZzFmJrM7cIJRq6fVetyABQRjYZYsQzLYycEOpMXZzZzACEqDhRkN7Fmx
cTPsj40aEUSxxuyPDR4RhLN/pxtSrUHKpqc/FhYRxG5m7MtGRQwM4nJ4dlsjOWwCJynCBdiUIGwV
h03ilFZFOY+tFoRNcdgqXKMm1c5j04Kw1Ry2miAJnHAeWysIm+awaYJyyfvWCcLWcNga9iCK005j
q3FB2FoOW0voKJ3WeWxCELaOw9aRJLvInMcmhWCzi5qNL0qcVNEa59e3WlBsIQgOmyBp3BU6FxRb
CJLDJkktpdU5jy0othAqDptSqTSEC7A1grApDlvNniZIjfPYgmILSDdZbFqlVRPOxxa1oNhC0By2
ht3FCOd9jRYUWwgNh62lVGq183GNFhRbCC2HraPUGhesb1pYbAFxjVSyOxBBuQBbUGwhcQ6bUONq
F5yZaEGxhSQ4bNbapM75eE4LOjuQJIfNmpvWOR9baEGxhVRx2GoaJ1ywj9GCYgtJcdg0TeJa52ML
LSi2kGoOW0NTatr5c6pGUGwhaQ5bS2tUKud1rhEUW0gNh62jdRrC+b1EIyi2kCCuqZSsFK5zfn1r
hMUWHYfNpsPsJuQ8tqDYosI5bJJ1Ntr5vUQj6NyiIjhslUbLupvz2ILimorksNmthFS7AFtQXFOp
OGy1lnJFPqYRFNdUFIdNa2lK4wJfExTXVGoOmzW3Ruu8zrWC4pqK5rC1OkKldf68phUU11QaDlun
U9GuwBYU11QgrlFKXKfWuQJbUFxT6ThsQqdVucLeguIahXPYKpzNZ5yPa1pBcY0iOGwKJ7Va59e3
VlBco0gOmz2mklqV89iC4hql4rBpNhS7wt6C4hpFcdga9geuwBYU1yg1h60j1CrCeV/TCYotFIhr
aiVOsOdz0nlsQbGF0nDYBImTLsiBdYJiC6XlsEGJS+e8vXXCYouOw1aRNI67AFtQbFHjHDZF/n97
1/rbNq7sPyd/BXE+pb11yjcp4eLipulji25So85uF+fgIFBsuRHqWFk/0vT+9WeGklU/ZEcM07R7
VwM0tSVaPz6GM8OZIaWtCNXfXgpUMQcMS1AT7Ez14nDFHbAWD7AS82JvJRywEVJGocBevK2kA7YC
pnTwnPYCVg44EhENNhb8uBqlmD6kEvczBAJ7qUtlHDCTkgUvd710pbIOmEstg7naS1GqyAELCVZ4
KHN5aUlNHbBUjAevsJmX6NLMISslePB8Yl6yS3OHrJXSOnRCMS/hpYVDNsqyYF8K85JeWjpkq6kK
jvAyL/GllUOOQFXY4HH2kl8a5Zc5pFrp4EnFvASYNg6ZaROFI3tJMG0dMjcU9GMospcI05FDFoab
4PUV85JhhjpkaZSwobzNvWSYYQ5ZGaN06LqOe8kwwx2yZhj6J6fp7FOaTM6rrFAA3qxNiS4UOZ2P
RmQ4H/dnGdTh4DQng2SWPNk2x7rw7wwwRYGplAQLuw6zrrFWk+4kv0jJh/TPeTqd3TGdXCOr5wCo
LEBhJUUjcpLP8kk+Ss6tjS8u4pRu72JaY+81XEH++QXqiWt1gFcO3jAldX0/N2/z1om80eZCcBlY
wolvHW2HsRbx4AJBNypSAktYiSyQp9f5eFryllTN5Fc2ycYJVKCQX0axCJTlP7/epqPj/Oo8pbFO
46He2umwHNnka+CWRtijUXaF2IUEgykFEzqwx7cKsI0ej0pQgBX1Dd7W5QyGqK7LlWw2octm20KI
WaFkxAKbvZXL15ttC/llI+hrGga6XXBugBaiKwIxEolA0K1dvAGKssseUpzHgbKLbzX5NkBlAQqs
DI0OA91q7W2AqgIUTEy6xfbYxsochG0dK1M/S8DqsgaRCs584V52lzUOmUUsCvY/cS+7y1qHzCMp
grM/uF9vRw5ZRNoGx464l90VUYcsRRQ+kbcuKdbZO2IFaBRZsAfCQLeuJjZAuQNVCloqA0EbWz5R
IbKUZgoafZxN+3nn1+zcmphFMczyLahC2BrLBwyJRkP7OR2Nvp5P5qN0CjWQZQ1g7abqa7DVEJG1
hgjUoxlzr9ajEGmWaslCl1PCa9kcFaIMPW/bhGlzZK9lc4SiLAKBwqx6WAN/i2ADAz+yJSaPRL2+
2ooJ8q+G13fbX4uWRiXq9kWUt8ISPm4ZhvvQoAaCWSlC1UZD/l4gM4cs0YsezF8+whttA0RWXLEH
SMP2QhYOWXOlRDCyz6KZUemQDTeRDHbh+3GYcshWUBjqUGQfCYaDi8gwoa0KRvaRYIyCBGP0kAql
wjnMx/HHqHXIsDJTwQ5er00dDEwSROYiilRwoN/HAGWY4g/IQnKhgtMbvGQYJvgjMu4VfWBNtSnR
ClcUw8R+xAQbEBaulVfIDAExHm73CoHUq3H50WZ8XbiFrOCALxy+pEKKQNNXNF04M8zqR1AtpAoF
bbpwdrvHHajFIODD+KKaKarCF8Uwp5/hPiltgL1CfVEN840LpwwGaRw2nuemA3u8qdeAMVuCKiMf
yhfVMNV50exCiikrpA10lmw3t9ebzQsBpqXAvTphoE1Xk4wXssvAPLaBCzvRdDXJeCG8DLA2rJKq
ZZVOYq7jC7prgJfM7KXxjep2ZH2oGd5s/Hn6dQo1KMSXAUliAp2Noul6lvFCfKEcCe7rpq50xlUJ
avS2KLP34sJrzyHjhfyKlDYqOH3DywDDzH3GDqmKWLDp57X3jWHePiAza4L9JdvXUxtDHTlQLk24
AGnqQWeYqQ+ggppgpt6+itoAZQUoj6S0wZ6hhltRlj0yDBP1oQZgFZjgDQpeW/wYpukDsgLpGRzg
9trgxzBJH5DBDNHBGwS8tvcxTNFnHFZSkd0SeL2vhb1l/QwWNqbmI6akEa03Nv18QdvXyystNSWq
Qmv3YcS117Y+hqn5WAOwfXhw0puX0MTEfEBmVoVvyvfaToixckTm1kQ8dNXqtZkQdxAisoiAz4Lb
7LVqxZR8QJYR8E2oWvbaSMgwIR+QFVhtLDi70UuCYTo+IOvI6GBvo9cmQiYLCWbdGVOhyF6eN1nI
sYiC2RnK214bCPEJsCA7pFQaEWp+eW0fZJiGD8iMGh6cZui1eRBVMiJzGoHeCEX2kWE/+vieYNp1
/hv9Eee/cdOe//aI1J7/9vemjfmfno/Pk4fFuGP+w9RfOv9V4vm/guv2/LdHoWQOU3+U72d4yjd8
KA5zHeX59UXS/7y/7+6ns0talsCPRZnBZf+6vO+URVnAfV4qsfclm6SweJ92UidZCr25d5lPZ2NQ
uWSap58n2bRDl57Flp7F7vEstr9cmaR4AozzLOtXZ6niCbPwFBewc+fVVneg8FUy/UzqT6i9qOyI
xS/h/v6eq0RyPSDP01n/efll8f+hq8chHqxcPWd+TcbJ7HB6WfaY69h/LJ5Jn3P5j+VWsAat4Pdu
BW/cCrarFWy5FbxqxQqVP2xVyc9BYef/N7MN/ew/PP9fiFb+Pw619t/fm3av/6b9ZByOsXv+M8ao
WD//XyjVzv/HoBe9HpE0lklMRVzF+g/ycWGWPNnfO+u9jgkzwlJBTWRAMpP5NO2TA04HzwjlsTQx
w4LDSfpnTLjkfH/vovCqOP1xk4zgAZTu7/WT6+QiG2WzrzF5BcDdSXaT9L+S3mU+mXVBAF1djNLi
W2+Uz84ysOkO6C2VgsHzp9mnMT6Ks+fuaSM0X6ZpOoZLgktyNSXJp3x/7+14mE+uEhd2AGvxKh3P
pmQ4ya/W/PTlKf77e+jPiUmRhLDXm19fAz7IxEmC5+nj+aVP8aDBp3jgwVMX2XxK9vdeQvUTfAC0
EGoxi0n5ohQi9vdefejG5DQfw//n0K4pVIH8Nk3hcz5LXUBkf+9D7zTeI0/J7+kED/4HILC/4Pub
SQ5WVT+7vkwnMTl797ZbXO8m2eRLBtUubkHNjo9PuksFjuazSwDK+kXTp/PM1b/be1fcP170foaX
sV+BoF9f3c7S8QAaPF1vuj6kJIJ/GJggzMIfLuGPwOsSvyr8ur/3sXv0aE1BhsXXUch4wOLKwfeN
YUmnQ0CH5f0M2jAo2VcwqYyUwlq24F4BzMtUzHms5BLzSuPLvK4j2TKDRmKDQYXiofxZLnaa8efm
yO3iWFvLsbs4YwsfnJzExfguYG4KjlgwxItXMNQfod87jOLWoqO3r3unOGHczXd1N01x8/e37qbp
4D7R4g5/Rs7+eN8lglLrBrUs+T4mSf8KS4uOWS/MFJVl4Y/d3hrXwgLJPeJj1nmdkXKyQqN76Qz4
uAdLLzCKODk4dm/ImU/SwZPiB9WQnYFxDKNNDo665a3ffsPB0wKPs1ACmsai4gWejHPboTSlso8v
6BSqKH+SjOdgcc/g6TBndrwXtCyeD1JgufIFoUvXyOn86gIfsfLC0KJAL51kybcSa28QLefoBMTh
5Ct5md5k/UXD4ClU0SGnslOOaHkbl99FLfBdo6W8cb1EgBEu8wHwzOKtMs/Ir8lFOnpGui+O3XTu
07jPYvhbZRJs6h+K26wNV9JEtJzBjBf6R9lYmaUprO+nf1Y1zsqEltGmxrE2dEIvZzY0nNZrMric
dtsnNmPlzF5VPuRFMvmcTs4XKvccOeaHaySmO92zd72jzofjUjv1m2snWci4X85If/mhgLMKQm+Z
HaKkgKIcp/te74R08y/Qc73kJiWDbJpAjwzwzoc/oOkw2sMsHS0u4K9I783b6qusvp79QXpnwNLw
8TTHN/Usvp0kt+TopPfyNzJKx59mlzExkVDF+3rw/ster/f8+Pide9q+K59dza/wEUcn3epnRCu1
+Bk5SG+Bp6BzsUmUCpQ2J9l49XczZOfpddLPxp9iYst5A+U1Foe+gpInxz3XoTBXBuktPLnqZ3gy
SNui4FlNwWSSElgUpsNsjP0FpfLrdOKGOi7G97qUISU7xo4f8QbUA4TZ0i2SD4eOc8f5t5ulsDo7
qkp9yQbYfTAEJ7/8Xyl6QbxDTYsvUIfrisvxYeMOXLrKbt2AQgG88uY1FHIaruLw9yiGttwbzEFU
FvKkwnHXjs96K2h0Ud8Xx+vlf+303r4pFBDOwup69/g96KpZdpOuXLq+TKbFlYr7V7ga27ksdF7d
Ygd9AtN5MXYPqt16INRcyQ/pp2w6myQTx3QNVR+9MAkVF7ozGErRuegPZSdS/X4nGTAaJbDskzyt
U30uv2xFyf1a5JGSV6DxaZ2qu4E2HlJRq+Qkv79eqwFeV25LKu1RzeHGcvRO22zeOer2Xv58dlpp
8HMdD3nct/FQxrJfYyFwzg36GTSeJ1taCBItBBELG/PlFarwNvLvshA03bAQmDa6MhEKjX80ugZZ
CTMGHuaY4XvpfQ2d8vYkJi/hL7DqHJafvPjShVmRD2CavshmV8k18vFsko9wPpeX/kX/XcxuZzj8
v7UU2knadJLeNUF/tAurpQDa9f5fBp9G4ek/fvEfSdH/azRt/b+PQW385+9Nu+O/jxL/0UzypfiP
cfEf0+b/PQrtjv+w1fiPttIYyWviP/oR4z8dBbYcJYMXV6v2Nr6LqY0BtTEgtiMGFGnNeF0MKHrg
GFBHiDombeNAP51/oY0D/SxxIPTyyFiYuDpldUMPKY0nsFlFNa30kFaohyL0EHG7NI3Zg8eBOobX
TWo8OmDN0/PtKNeGE5Xzu0I5my4dtuLS4U1dOjt10nd1+Pz1dZSPeio8ltWRJRu8LKy2Gn2WC0Z2
9hSLqVzj4/t5K5vbU5rV21Nq3X9ZHI3SXPU8rUbl6d3KB2arY+sJNOblq71X45tsko+vXCjm7XiQ
55Pn7+cz/B+DesWPpuRfjHQIE/8m/4tRIdeGn8aoelQXo5va/z3OyRB3rf3PXUr76T209s8aIWgU
9WUyXUR9n5dx1t2h3+XQbhnMJbAinuG0qo/qCnwLz18hqmseNKjL74rpJhf5Tbo1mJuMvz5EJJf+
5JHcx7QyF37VjvvDqk+gavSQ26EWg4s6K7M84+AZyNv+ql358fQDPuaG11mWv/NfWK1BCeOQ3t+K
rDA7vx8ffCx3/pCjbocfyjdPPGzLotNeg2kzHjhhIO5IO/rm9sC0I8mpwSNg19OOopjy75p21FG1
5qaOdJt69PMFFNvUozb1qE09alOPNtVgm3r0F11YLBbyPGY0rg553bQSRMRsZAUzQlepR7qwEoSN
2Xd2Stn65buWstYphQfJeniPPX1S1NMnRQ7+C7RDDnN8Nn3iYzEEe4PKwaXDWOu4OgRzY3C5QJej
UlyLZTeNjoWM6XLUoHlSWc2I0lU3Y32ASzC+NqKLkzW/XxpZzYB4GkY/OsLZ0i7anf8D3NApmaFj
741xZ/4Ppav7vzF1krXx/8eguvEfgaX1AGlfFfnt/xcw/lJS2Y7/Y1Cb/9VSSy211FJLLbXUUkst
tdRSSy211FJLLbXUUksttdRSSy211FJLLbXUUksttdRSSy211FJLfx36D9xI71kAmAMA
--e89a8f234567783ff104bec4db4b--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
