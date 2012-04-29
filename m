From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Sun, 29 Apr 2012 19:49:36 +0200
Message-ID: <CA+icZUUj8utveS7e6wh-BU3A4yk4FsiQ9YGRk6BowL+ex35wFw@mail.gmail.com>
References: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
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
	<CA+icZUVT6kvqj47x26FU2qjbMHc=jr9_Lso=zduf_cmcSrv=UQ@mail.gmail.com>
	<CAJfuBxwz2PmNY37VB7Wx+GdQcOcS6Y96EM_JNtvs-dyv-imL6g@mail.gmail.com>
	<CA+icZUXrGuY+0GLJCmL9CH7i7vnvXAyAE2vXNAXM_3Q30B4nPA@mail.gmail.com>
	<4F9D7BB8.4000007@coldplug.net>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: admin <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F9D7BB8.4000007-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 29, 2012 at 7:34 PM, admin <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org> wrote:
> On 04/29/2012 01:26 AM, Sedat Dilek wrote:
>>
>> On Sun, Apr 29, 2012 at 1:11 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =C2=
=A0wrote:
>>>
>>> On Sat, Apr 28, 2012 at 4:49 PM, Sedat Dilek<sedat.dilek@googlemail=
=2Ecom>
>>> =C2=A0wrote:
>>>>
>>>> On Sun, Apr 29, 2012 at 12:36 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>> =C2=A0wrote:
>>>>>>>
>>>>>>> As already pointed out, no Marwell WLAN hardware here. Marvell =
comics
>>>>>>> of course :-).
>>>
>>> (I had to leave that one..:-)
>>>
>>>
>>>
>>>>>> A new tarball from lautriv with same outputs as before, but now =
tested
>>>>>> with Linux-3.4-rc4.
>>>>>>
>>>>>> - Sedat -
>>>>>
>>>>>
>>>>> heres my logs, using firmware extracted by Sedat's script,
>>>>> and the patch on mwl8k.c
>>>>>
>>>>> bottom-line, it appears to be working.
>>>>>
>>>>> its contents are a bit more pedantic, and includes data for
>>>>> another wifi card (rtl8180 based) also in the box.
>>>>> It was obtained by this script:
>>>>>
>>>>> #!/bin/bash
>>>>>
>>>>> # dmesg (Linux-3.3.3)
>>>>> # e_n_a (/etc/network/interfaces)
>>>>> # ifconfig output
>>>>> # iwconfig output
>>>>> # iw_phy output
>>>>> # ps_axu (WPA) output
>>>>>
>>>>> devs=3D"wlan0 wlan1"
>>>>> apmac=3D00:14:d1:e8:65:0a
>>>>>
>>>>> loudly () {
>>>>> =C2=A0 =C2=A0echo "# $@"
>>>>> =C2=A0 =C2=A0fname=3D`echo $@ | sed -e 's/ /-/g'`
>>>>> =C2=A0 =C2=A0$@ 2> =C2=A0$fname-err | tee $fname
>>>>> =C2=A0 =C2=A0[ $? !=3D 0 ]&& =C2=A0echo non-zero exit on $fname: =
$?
>>>>> =C2=A0 =C2=A0[ -s $fname-err ] || rm $fname-err
>>>>> }
>>>>>
>>>>> ( iw --debug event -f> =C2=A0iw-event-f )&
>>>>> pid_event=3D$!
>>>>>
>>>>> for N in 0 1 ; do
>>>>> =C2=A0 =C2=A0loudly iw dev wlan$N interface add fish$N type monit=
or # flags none
>>>>> =C2=A0 =C2=A0loudly iw dev fish$N set channel 8
>>>>> =C2=A0 =C2=A0loudly ifconfig fish$N up
>>>>> =C2=A0 =C2=A0( tcpdump -i fish$N -s 65000 -p -U -w =C2=A0fish$N.d=
ump )&
>>>>> =C2=A0 =C2=A0pid_dump_fish$N=3D$!
>>>>> done
>>>>>
>>>>> loudly iw list
>>>>>
>>>>> #loudly iwspy
>>>>> # gives: Interface doesn't support wireless statistic collection
>>>>>
>>>>> for dev in $devs ; do
>>>>> =C2=A0 =C2=A0loudly ifconfig $dev
>>>>> =C2=A0 =C2=A0loudly iwconfig $dev
>>>>> =C2=A0 =C2=A0loudly iwlist $dev scan
>>>>> =C2=A0 =C2=A0loudly iw dev $dev info
>>>>> =C2=A0 =C2=A0loudly iw dev $dev link
>>>>> =C2=A0 =C2=A0loudly iw dev $dev scan
>>>>> =C2=A0 =C2=A0loudly iw dev $dev survey dump
>>>>> done
>>>>>
>>>>> for phy in $phys ; do
>>>>> =C2=A0 =C2=A0loudly iw phy $phy info
>>>>> done
>>>>>
>>>>> # these are unsupported on wlan0
>>>>> loudly iw dev wlan1 survey dump
>>>>> loudly iw dev wlan1 station dump
>>>>> loudly iw dev wlan1 station get $apmac
>>>>>
>>>>>
>>>>> for N in 0 1 ; do
>>>>> =C2=A0 =C2=A0loudly iw dev fish$N del
>>>>> done
>>>>>
>>>>> kill $pid_dump_fish0 $pid_dump_fish0
>>>>> kill $pid_event
>>>>>
>>>>> dmesg> =C2=A0dmesg
>>>>>
>>>>> grep -vE '^#|key' /etc/network/interfaces> =C2=A0e_n_a
>>>>>
>>>>> exit
>>>>
>>>> Hi Jim,
>>>>
>>>> thanks for your testing and the nice testcase-script!
>>>>
>>>> lautriv you wanna run some more tests with Jim's script?
>>>>
>>>> Jim, how stable/fast/reliable is your WLAN connection?
>>>> Suspend/resume tested?
>>>
>>> I havent tested reliability in any way.
>>> in fact, I havent tested any data-xfer per se,
>>> will do an iperf test soon.
>>>
>>> That said, bitrate is quite low, I havent looked at why.
>>>
>>> jimc@chumly:~/projects/lx/wifi/mwl8k-8361p-logs$ grep -i MBit *
>>> iw-dev-wlan0-link: =C2=A0 =C2=A0 =C2=A0tx bitrate: 11.0 MBit/s
>>> iw-dev-wlan1-link: =C2=A0 =C2=A0 =C2=A0tx bitrate: 1.0 MBit/s
>>> iw-dev-wlan1-station-dump: =C2=A0 =C2=A0 =C2=A0tx bitrate: =C2=A0 =C2=
=A0 1.0 MBit/s
>>> iw-dev-wlan1-station-get-00:14:d1:e8:65:0a: =C2=A0 =C2=A0 tx bitrat=
e: =C2=A0 =C2=A0 1.0
>>> MBit/s
>>>
>>> my laptop is much faster than both cards in the soekris box, to sam=
e AP
>>>
>>> Connected to 00:14:d1:e8:65:0a (on wlan0)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0SSID: yoduh
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0freq: 2447
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0RX: 191134302 bytes (2120068 packets)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0TX: 17440426 bytes (120666 packets)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0signal: -45 dBm
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0tx bitrate: 54.0 MBit/s
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0bss flags:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dtim period: =C2=A0 =C2=A00
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0beacon int: =C2=A0 =C2=A0 100
>>>
>>>
>>> If you all have some suggestions on this, Id like to hear them.
>>> And of course, any other testing you'd like too.
>>>
>>>
>>>> Hope this helps to get native Linux support for 8361p.
>>>
>>> hear hear.
>>> FWIW, =C2=A0I pulled this card out of a dead Netgear WNR854T,
>>> which is linux based (and GPL compliant)
>>>
>>>> Regards,
>>>> - Sedat -
>>>>
>>>> P.S.: BTW, only to clarify it should be "e_n_i" as short-form for
>>>> /etc/network/interfaces file, but e_n_a sounds more female and nic=
er
>>>> :-).
>>>
>>> I caught that, but it wasnt worth "correcting" ;-)
>>>
>>> thanks
>>> Jim
>>
>> Unfortunately, [1] says not much about debugging.
>> Anyway, Lennert has some new informations.
>> Let's see what the experts will say.
>>
>> - Sedat -
>>
>> [1] http://wireless.kernel.org/en/users/Drivers/mwl8k
>>
>
> ok, as far as i can see for now, it looks like the actual solution is
> ignoring/rejecting any manual command to set parameters, neither iwco=
nfig
> nor iw will change any settings. wpa_sup brings the card up and does =
also
> WPA2 but nothing else is tuneable thus a connection via 1Mb/s.
>
> attaching a tarball from the results of the script which produced 42 =
files
> of output.
>

Credits for the script go to Jim, not me!

- Sedat -
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
