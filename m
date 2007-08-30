From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Thu, 30 Aug 2007 13:09:11 +0400
Message-ID: <46D68937.7030305@bigtelecom.ru>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:52026 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbXH3JJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 05:09:48 -0400
In-Reply-To: <20070830072718.GC1677@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Aug 30, 2007 at 08:31:10AM +0200, Jarek Poplawski wrote:
>  =20
>> On Thu, Aug 30, 2007 at 12:16:32AM +0400, slavon@bigtelecom.ru wrote=
:
>>    =20
> ...
>  =20
>>> PS. And also have we have strange bug in another computer (2.6.22-r=
5).
>>> Have computer XEON_CPUx2 (4 CPU)
>>>
>>> after boot have CPU0 and CPU3 SI =3D ~50%
>>> after some time CPU0 SI =3D 0% and ksoftirqd/2 process have 100% cp=
u usage!
>>> nat-new ~ # cat /proc/interrupts
>>>            CPU0       CPU1       CPU2       CPU3
>>>   0:        403          0          0          0   IO-APIC-edge    =
  timer
>>>      =20
>> ...
>>    =20
>>> LOC:   89312505   89314019   89310139   89313972
>>> ERR:          0
>>> MIS:          0
>>>
>>> changes only LOC interrupts!
>>>
>>> Maybe its info intresting for you. =3D)
>>>      =20
>> Yes. It seems something loops or breaks with disabled interrupts. If
>>    =20
>
> On the other hand disabling local interrupts shouldn't be enough here=
,
> so it's really strange... Did you get this remotely? Are you sure LOC
> only? (Anyway this 2.6.23-rc4 should be interesting.)
>
> Jarek P.
>
>  =20
Only LOC changes... icmp answer =3D 50-70ms... after 1-2 hours traffic=20
level is down and SI on CPU0 and CPU2 change to above 50%. ksoftirqd=20
free CPU usage. I have this bug 3-4 times in week. If you need info wha=
t=20
i can see only in bug still processing - i may try get this info for yo=
u.

maybe help:

1U server INTEL, mb se7501w2

nat-new ~ # lspci
00:00.0 Host bridge: Intel Corporation E7501 Memory Controller Hub (rev=
 01)
00:00.1 Class ff00: Intel Corporation E7500/E7501 Host RASUM Controller=
=20
(rev 01)
00:03.0 PCI bridge: Intel Corporation E7500/E7501 Hub Interface C=20
PCI-to-PCI Bridge (rev 01)
00:03.1 Class ff00: Intel Corporation E7500/E7501 Hub Interface C RASUM=
=20
Controller (rev 01)
00:1d.0 USB Controller: Intel Corporation 82801CA/CAM USB Controller #1=
=20
(rev 02)
00:1d.1 USB Controller: Intel Corporation 82801CA/CAM USB Controller #2=
=20
(rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 42)
00:1f.0 ISA bridge: Intel Corporation 82801CA LPC Interface Controller=20
(rev 02)
00:1f.1 IDE interface: Intel Corporation 82801CA Ultra ATA Storage=20
Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801CA/CAM SMBus Controller (rev 02)
01:0c.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27=
)
02:1c.0 PIC: Intel Corporation 82870P2 P64H2 I/OxAPIC (rev 04)
02:1d.0 PCI bridge: Intel Corporation 82870P2 P64H2 Hub PCI Bridge (rev=
 04)
02:1e.0 PIC: Intel Corporation 82870P2 P64H2 I/OxAPIC (rev 04)
02:1f.0 PCI bridge: Intel Corporation 82870P2 P64H2 Hub PCI Bridge (rev=
 04)
03:07.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet=
=20
Controller (Copper) (rev 01)
03:07.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet=
=20
Controller (Copper) (rev 01)
04:08.0 RAID bus controller: Intel Corporation RAID Controller

