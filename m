From: Helmut Stengele <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Mon, 30 Apr 2012 11:53:33 +0200
Message-ID: <4F9E611D.2080309@coldplug.net>
References: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com> <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com> <20120427095842.GW3157@wantstofly.org> <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com> <20120427101732.GX3157@wantstofly.org> <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com> <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com> <20120427185809.GZ3157@wantstofly.org> <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com> <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com> <CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com> <CA+icZUVT6kvqj47x26FU2qjbMHc=jr9_Lso=zduf_cmcSrv=UQ@mail.gmail.com> <CAJfuBxwz2PmNY37VB7Wx+GdQcOcS6Y96EM_JNtvs-dyv-imL
 6g@mail.gmail.com> <CA+icZUXrGuY+0GLJCmL9CH7i7vnvXAyAE2vXNAXM_3Q30B4nPA@mail.gmail.com> <4F9D7BB8.4000007@coldplug.net> <CA+icZUUj8utveS7e6wh-BU3A4yk4FsiQ9YGRk6BowL+ex35wFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUUj8utveS7e6wh-BU3A4yk4FsiQ9YGRk6BowL+ex35wFw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/29/2012 07:49 PM, Sedat Dilek wrote:
> On Sun, Apr 29, 2012 at 7:34 PM, admin<admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>  wrote:
>> On 04/29/2012 01:26 AM, Sedat Dilek wrote:
>>> On Sun, Apr 29, 2012 at 1:11 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>    wrote:
>>>> On Sat, Apr 28, 2012 at 4:49 PM, Sedat Dilek<sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
>>>>   wrote:
>>>>> On Sun, Apr 29, 2012 at 12:36 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>>   wrote:
>>>>>>>> As already pointed out, no Marwell WLAN hardware here. Marvell comics
>>>>>>>> of course :-).
>>>> (I had to leave that one..:-)
>>>>
>>>>
>>>>
>>>>>>> A new tarball from lautriv with same outputs as before, but now tested
>>>>>>> with Linux-3.4-rc4.
>>>>>>>
>>>>>>> - Sedat -
>>>>>>
>>>>>> heres my logs, using firmware extracted by Sedat's script,
>>>>>> and the patch on mwl8k.c
>>>>>>
>>>>>> bottom-line, it appears to be working.
>>>>>>
>>>>>> its contents are a bit more pedantic, and includes data for
>>>>>> another wifi card (rtl8180 based) also in the box.
>>>>>> It was obtained by this script:
>>>>>>
>>>>>> #!/bin/bash
>>>>>>
>>>>>> # dmesg (Linux-3.3.3)
>>>>>> # e_n_a (/etc/network/interfaces)
>>>>>> # ifconfig output
>>>>>> # iwconfig output
>>>>>> # iw_phy output
>>>>>> # ps_axu (WPA) output
>>>>>>
>>>>>> devs="wlan0 wlan1"
>>>>>> apmac=00:14:d1:e8:65:0a
>>>>>>
>>>>>> loudly () {
>>>>>>     echo "# $@"
>>>>>>     fname=`echo $@ | sed -e 's/ /-/g'`
>>>>>>     $@ 2>    $fname-err | tee $fname
>>>>>>     [ $? != 0 ]&&    echo non-zero exit on $fname: $?
>>>>>>     [ -s $fname-err ] || rm $fname-err
>>>>>> }
>>>>>>
>>>>>> ( iw --debug event -f>    iw-event-f )&
>>>>>> pid_event=$!
>>>>>>
>>>>>> for N in 0 1 ; do
>>>>>>     loudly iw dev wlan$N interface add fish$N type monitor # flags none
>>>>>>     loudly iw dev fish$N set channel 8
>>>>>>     loudly ifconfig fish$N up
>>>>>>     ( tcpdump -i fish$N -s 65000 -p -U -w  fish$N.dump )&
>>>>>>     pid_dump_fish$N=$!
>>>>>> done
>>>>>>
>>>>>> loudly iw list
>>>>>>
>>>>>> #loudly iwspy
>>>>>> # gives: Interface doesn't support wireless statistic collection
>>>>>>
>>>>>> for dev in $devs ; do
>>>>>>     loudly ifconfig $dev
>>>>>>     loudly iwconfig $dev
>>>>>>     loudly iwlist $dev scan
>>>>>>     loudly iw dev $dev info
>>>>>>     loudly iw dev $dev link
>>>>>>     loudly iw dev $dev scan
>>>>>>     loudly iw dev $dev survey dump
>>>>>> done
>>>>>>
>>>>>> for phy in $phys ; do
>>>>>>     loudly iw phy $phy info
>>>>>> done
>>>>>>
>>>>>> # these are unsupported on wlan0
>>>>>> loudly iw dev wlan1 survey dump
>>>>>> loudly iw dev wlan1 station dump
>>>>>> loudly iw dev wlan1 station get $apmac
>>>>>>
>>>>>>
>>>>>> for N in 0 1 ; do
>>>>>>     loudly iw dev fish$N del
>>>>>> done
>>>>>>
>>>>>> kill $pid_dump_fish0 $pid_dump_fish0
>>>>>> kill $pid_event
>>>>>>
>>>>>> dmesg>    dmesg
>>>>>>
>>>>>> grep -vE '^#|key' /etc/network/interfaces>    e_n_a
>>>>>>
>>>>>> exit
>>>>> Hi Jim,
>>>>>
>>>>> thanks for your testing and the nice testcase-script!
>>>>>
>>>>> lautriv you wanna run some more tests with Jim's script?
>>>>>
>>>>> Jim, how stable/fast/reliable is your WLAN connection?
>>>>> Suspend/resume tested?
>>>> I havent tested reliability in any way.
>>>> in fact, I havent tested any data-xfer per se,
>>>> will do an iperf test soon.
>>>>
>>>> That said, bitrate is quite low, I havent looked at why.
>>>>
>>>> jimc@chumly:~/projects/lx/wifi/mwl8k-8361p-logs$ grep -i MBit *
>>>> iw-dev-wlan0-link:      tx bitrate: 11.0 MBit/s
>>>> iw-dev-wlan1-link:      tx bitrate: 1.0 MBit/s
>>>> iw-dev-wlan1-station-dump:      tx bitrate:     1.0 MBit/s
>>>> iw-dev-wlan1-station-get-00:14:d1:e8:65:0a:     tx bitrate:     1.0
>>>> MBit/s
>>>>
>>>> my laptop is much faster than both cards in the soekris box, to same AP
>>>>
>>>> Connected to 00:14:d1:e8:65:0a (on wlan0)
>>>>         SSID: yoduh
>>>>         freq: 2447
>>>>         RX: 191134302 bytes (2120068 packets)
>>>>         TX: 17440426 bytes (120666 packets)
>>>>         signal: -45 dBm
>>>>         tx bitrate: 54.0 MBit/s
>>>>
>>>>         bss flags:
>>>>         dtim period:    0
>>>>         beacon int:     100
>>>>
>>>>
>>>> If you all have some suggestions on this, Id like to hear them.
>>>> And of course, any other testing you'd like too.
>>>>
>>>>
>>>>> Hope this helps to get native Linux support for 8361p.
>>>> hear hear.
>>>> FWIW,  I pulled this card out of a dead Netgear WNR854T,
>>>> which is linux based (and GPL compliant)
>>>>
>>>>> Regards,
>>>>> - Sedat -
>>>>>
>>>>> P.S.: BTW, only to clarify it should be "e_n_i" as short-form for
>>>>> /etc/network/interfaces file, but e_n_a sounds more female and nicer
>>>>> :-).
>>>> I caught that, but it wasnt worth "correcting" ;-)
>>>>
>>>> thanks
>>>> Jim
>>> Unfortunately, [1] says not much about debugging.
>>> Anyway, Lennert has some new informations.
>>> Let's see what the experts will say.
>>>
>>> - Sedat -
>>>
>>> [1] http://wireless.kernel.org/en/users/Drivers/mwl8k
>>>
>> ok, as far as i can see for now, it looks like the actual solution is
>> ignoring/rejecting any manual command to set parameters, neither iwconfig
>> nor iw will change any settings. wpa_sup brings the card up and does also
>> WPA2 but nothing else is tuneable thus a connection via 1Mb/s.
>>
>> attaching a tarball from the results of the script which produced 42 files
>> of output.
>>
> Credits for the script go to Jim, not me!
>
> - Sedat -
>
So i investigated in a bit further testing, where my router was taken 
into account too.......

Seems the patch/driver/hardware works a bit better than one can see from 
the output.

i changed my router to different setups with a/b/g/n g/n and n only and 
even the testbox
reported always 1Mb/s , my router found the device connected to certain 
other speeds
such as 24/84/120/240 depending on his own rules.

When in N-only, the router insisted on AES instead TKIP which may be 
somewhere defined,
however the card itself followed the rule silently ( i held wlan0 up ).

speed result was not that magic, gave me an average of 2.2MB/s in mixed 
mode and
3.6 MB/s in N-only ( where the router showed a connection with 240 Mb/s 
) while my signal
was always between 96 and 100%.

Because this device was made for winblows only, i could imagine they 
byte-swapped
or moved an offset and it may be worth to compare some kind of 
register-dump right after init
with another topdog like 8363.

Helmut.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
