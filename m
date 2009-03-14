From: Tim Durack <tdurack@gmail.com>
Subject: Re: [BUG] 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Date: Fri, 13 Mar 2009 22:23:04 -0400
Message-ID: <9e246b4d0903131923lecba2bah940f41c9c5fa6b03@mail.gmail.com>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se>
	 <20090313201511.GA27827@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mikael Pettersson <mikpe@it.uu.se>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivecera@redhat.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f165.google.com ([209.85.217.165]:64044 "EHLO
	mail-gx0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbZCNC3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 22:29:24 -0400
Received: by gxk9 with SMTP id 9so566011gxk.13
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 19:29:21 -0700 (PDT)
In-Reply-To: <20090313201511.GA27827@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 4:15 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Mikael Pettersson <mikpe@it.uu.se> :
>> With the 2.6.29-rc7 kernel I'm unable to 'ifup' eth0 on my ARM-based
>> Thecus n2100 NAS box, which has an RTL8169 NIC (10ec:8169 (rev 10)).
>> A diff of the kernel logs from 2.6.29-rc6 and -rc7 shows that -rc7
>> first mangles and then zaps the MAC addresses:
>
> Can you apply the attached patch and see if it fixes any of these
> problems ?
>
> Tim, could you give it a try too ? It applies with "patch -p1" from
> the kernel tree directory.
>
> --
> Ueimor
>

No luck:

B-25-1NOC-CFG-1:~# modprobe -if r8169
[  120.938729] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  120.945018] r8169 0000:00:09.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[  120.953409] r8169 0000:00:09.0: no PCI Express capability
[  120.960359] r8169 0000:00:09.0: MAC address found in EEPROM:
00:30:18:ab:f0:34
[  120.978441] eth1: RTL8169sc/8110sc at 0xf8154000,
00:00:00:00:f0:34, XID 18000000 IRQ 18
[  120.988468] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  120.994119] r8169 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[  121.001139] r8169 0000:00:0b.0: no PCI Express capability
[  121.006922] r8169 0000:00:0b.0: MAC address found in EEPROM:
00:30:18:ab:f0:35
[  121.063615] eth2: RTL8169sc/8110sc at 0xf801e000,
00:00:00:00:f0:35, XID 18000000 IRQ 19
[  121.072495] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  121.078188] r8169 0000:00:0c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  121.085239] r8169 0000:00:0c.0: no PCI Express capability
[  121.091025] r8169 0000:00:0c.0: MAC address found in EEPROM:
00:30:18:ab:f0:36
[  121.147502] eth3: RTL8169sc/8110sc at 0xf8022000,
00:00:00:00:f0:36, XID 18000000 IRQ 16

Tim:>
