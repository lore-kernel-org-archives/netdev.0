From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: v2.6.30-rc4: b44: eth0: BUG! Timeout waiting for bit 00000002 of
	register 42c to clear.
Date: Sat, 16 May 2009 11:42:01 +0200
Message-ID: <8db1092f0905160242v7264a642m9978dd761c160e0c@mail.gmail.com>
References: <38b2ab8a0905030922x722a45f3gf0790b5b90b0f2b3@mail.gmail.com>
	 <200905031828.14468.florian@openwrt.org>
	 <38b2ab8a0905031012m5d50b68es22e3c80cfa72fd60@mail.gmail.com>
	 <200905152350.27270.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francis Moreau <francis.moro@gmail.com>,
	Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756585AbZEPJmx@vger.kernel.org>
In-Reply-To: <200905152350.27270.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/5/15 Rafael J. Wysocki <rjw@sisk.pl>:
> On Sunday 03 May 2009, Francis Moreau wrote:
>> Hello Florian,
>>
>> On Sun, May 3, 2009 at 6:28 PM, Florian Fainelli <florian@openwrt.or=
g> wrote:
>> >> I got this since I updated my kernel from 2.6.29 to 2.6.30-rc4.
>> >>
>> >> Let me know if you need more information.
>> >
>> > Is this seen on a Broadcom 47xx/53xx platform or on a computer wit=
h a PCI b44
>> > card ?
>> >
>>
>> $ lspci -vv
>>
>> 06:01.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base=
-TX (rev 02)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Subsystem: Acer Incorporated [ALI] Devic=
e 0090
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Control: I/O- Mem+ BusMaster+ SpecCycle-=
 MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B- DisINTx-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: Cap+ 66MHz- UDF- FastB2B- ParErr=
- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Latency: 64
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Interrupt: pin A routed to IRQ 21
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Region 0: Memory at d2000000 (32-bit, no=
n-prefetchable) [size=3D8K]
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: <access denied>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Kernel driver in use: b44
>>
>>
>> Let me know if you need more details.
>
> Can anyone please tell me what the status of this report is?
>

Hmm. I also have this message in dmesg when always back to Linux from
Windows XP, but only in this case and as long as I remember.

02:0e.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX=
 (rev 02)

Regards
--=20
Maciej Rutecki
http://www.maciek.unixy.pl
