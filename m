From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
	devices (v2)
Date: Mon, 15 Mar 2010 17:28:45 -0600
Message-ID: <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
References: <20100315150806.GA15354@Dublin.logfs.org>
	 <20100315151041.GA15667@Dublin.logfs.org>
	 <20100315.115748.13754030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joern@dublin.logfs.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:53483 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564Ab0COX2r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:28:47 -0400
In-Reply-To: <20100315.115748.13754030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 12:57 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: J=C3=B6rn Engel <joern@dublin.logfs.org>
> Date: Mon, 15 Mar 2010 16:10:41 +0100
>
>> Forgot to Cc: lkml.
>
> Actually, what you really need to CC: is netdev, added.
>> On Mon, 15 March 2010 16:08:06 +0100, J=EF=BF=BDrn Engel wrote:
>>>
>>> Hello Robert!
>>>
>>> Looks like 353176888386d9025062a12dcec08d49af10cf2c broke one of my
>>> machines. =C2=A0Reverting that patch fixes things again. =C2=A0Mach=
ine is
>>> running an x86_64 kernel. =C2=A0Lspci gives me this:
>>>
>>> 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL810=
1E/RTL8102E PCI Express Fast Ethernet controller (rev 02)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Subsystem: ASRock Incorporation Device =
8136
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Flags: bus master, fast devsel, latency=
 0, IRQ 26
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 I/O ports at e800 [size=3D256]
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Memory at fdeff000 (64-bit, prefetchabl=
e) [size=3D4K]
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Memory at fdee0000 (64-bit, prefetchabl=
e) [size=3D64K]
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 [virtual] Expansion ROM at fde00000 [di=
sabled] [size=3D128K]
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [40] Power Management ver=
sion 3
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [50] MSI: Enable+ Count=3D=
1/1 Maskable- 64bit+
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [70] Express Endpoint, MS=
I 01
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [ac] MSI-X: Enable- Count=
=3D2 Masked-
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [cc] Vital Product Data
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [100] Advanced Error Repo=
rting
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [140] Virtual Channel <?>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Capabilities: [160] Device Serial Numbe=
r 08-00-00-00-ff-ff-00-00
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Kernel driver in use: r8169
>>>
>>> If you have any test patches to try, please send them my way. :)
>>>
>>> J=EF=BF=BDrn
>

What are the symptoms? Does setting use_dac=3D0 in the module options
for r8169 also resolve the problem?

=46ull dmesg and lspci -vv output might also be useful.
