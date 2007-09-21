From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 21:33:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709212130490.11228@bizon.gios.gov.pl>
References: <200709211201.24475.vda.linux@googlemail.com>
 <200709211905.23946.vda.linux@googlemail.com> <15775.1190399812@turing-police.cc.vt.edu>
 <200709212018.06553.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1802889197-1190403219=:11228"
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	jeff@garzik.org, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:38093 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762573AbXIUTd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 15:33:59 -0400
In-Reply-To: <200709212018.06553.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1802889197-1190403219=:11228
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 21 Sep 2007, Denys Vlasenko wrote:

> On Friday 21 September 2007 19:36, Valdis.Kletnieks@vt.edu wrote:
>> On Fri, 21 Sep 2007 19:05:23 BST, Denys Vlasenko said:
>>
>>> I plan to use gzip compression on following drivers' firmware,
>>> if patches will be accepted:
>>>
>>>    text    data     bss     dec     hex filename
>>>   17653  109968     240  127861   1f375 drivers/net/acenic.o
>>>    6628  120448       4  127080   1f068 drivers/net/dgrs.o
>>>          ^^^^^^
>>
>> Should this be redone to use the existing firmware loading framework to
>> load the firmware instead?
>
> Not in every case.
>
> For example, bnx2 maintainer says that driver and
> firmware are closely tied for his driver. IOW: you upgrade kernel
> and your NIC is not working anymore.
Firmware may come with a kernel. We have a "install modules", we can also=
=20
add "install firmware".

> Another argument is to make kernel be able to bring up NICs
> without needing firmware images in initramfs/initrd/hard drive.

It is not possible to bring up things like FC or WiFi without firmware,=20
what special is in classic NICs?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1802889197-1190403219=:11228--
