From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Wed, 2 May 2012 09:59:30 +0200
Message-ID: <4FA0E962.7040402@broadcom.com>
References: <20120427094637.GV3157@wantstofly.org>
 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org>
 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org>
 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
 <20120501125102.GN3157@wantstofly.org>
 <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Sedat Dilek" <sedat.dilek@googlemail.com>,
	"Lennert Buytenhek" <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	"Jim Cromie" <jim.cromie@gmail.com>,
	"Ben Hutchings" <ben@decadent.org.uk>,
	"Hauke Mehrtens" <hauke@hauke-m.de>,
	"Xose Vazquez Perez" <xose.vazquez@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/01/2012 03:54 PM, Sedat Dilek wrote:
> On Tue, May 1, 2012 at 2:51 PM, Lennert Buytenhek
> <buytenh@wantstofly.org>  wrote:
>> On Sun, Apr 29, 2012 at 12:25:21AM +0200, Sedat Dilek wrote:
>>
>>>> On 1st sight, logs look fine:
>>>>
>>>> [21:52:52]<lautriv>  [    6.050967] ieee80211 phy0: 88w8361p v4,
>>>> 00173f3bdde3, STA firmware 2.1.4.25
>>>>
>>>> But WLAN connection is not that fast and stable as lautriv reports
>>>> (several abnormalities were observed).
>>>>
>>>> I requested a tarball which includes:
>>>> * dmesg (Linux-3.3.3)
>>>> * e_n_a (/etc/network/interfaces)
>>>> * ifconfig output
>>>> * iwconfig output
>>>> * iw_phy output
>>>> * ps_axu (WPA) output
>>>>
>>>> lautriv will be so kind to be around on #linux-wireless/Freenode the
>>>> next days (UTC+2: German/Swiss local-time).
>>>> Just ping him.
>>>>
>>>> Hope you have fun, together!
>>>>
>>>> - Sedat -
>>>
>>> A new tarball from lautriv with same outputs as before, but now tested
>>> with Linux-3.4-rc4.
>
> [ CC hauke (OpenWrt) and Ben Hutchings (linux-firmware maintainer) ]
>
>> The output looks good enough for me to ACK adding the PCI ID.
>>
>> Can the firmware being used here be submitted to the linux-firmware
>> git tree?
>
> I can't say much about the firmware [1] inclusion or the procedure of
> it into linux-firmware [2].
> Maybe, Ben can explain the procedure and what has to be considered
> before inclusion in linux-firmware.
> The original firmware and helper images were extracted from a Netgear
> Windows driver [1].
>
>  From what I read in the OpenWrt forum posting [3]: You wanted to care
> for inclusion:
>
> "Firmware isn't included in the kernel tree anymore, there's the
> linux-firmware git tree for that these days. I will contact some
> people at Marvell to ask whether 8361P firmware can be included
> there."

Basically, all firmware in linux-firmware repository should be 
accompanied with license information. Also you are signing off the patch 
to add the firmware to the repository so you are bound to the 
Developer's Certificate of Origin 1.1 in [1]. Having the firmware 
extracted from a windows driver does not fall under that statement, 
unless Marvell is ok with its redistribution. Recently a patch was 
submitted for a README in the linux-firmware repository about the 
process. It must be a binary patch. Easiest way is to use 'git 
format-patch -B'.

Gr. AvS

[1] http://lxr.linux.no/linux+v3.3.4/Documentation/SubmittingPatches
[2] https://lkml.org/lkml/2012/4/21/177
