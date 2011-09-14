From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: e1000e: NIC not working, power management issue?
Date: Wed, 14 Sep 2011 14:14:59 -0700
Message-ID: <CALWPMBEvwFbP-G+Ojfr_vM2riwG9vax3_3cQ1SzBR4OmdnHnsw@mail.gmail.com>
References: <20110914134042.GA5739@xanadu.blop.info>
	<1316032260.6309.1.camel@defected>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org,
	Lucas Nussbaum <lucas@lucas-nussbaum.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Frederik Himpe <fhimpe@telenet.be>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1316032260.6309.1.camel@defected>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2011 at 1:31 PM, Frederik Himpe <fhimpe@telenet.be> wrote:

>>
>> dmesg:
>> [ 6260.327320] e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
>> [ 6260.327324] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
>> [ 6260.327355] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> =
IRQ 22
>> [ 6260.327366] e1000e 0000:00:19.0: setting latency timer to 64
>> [ 6260.327490] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
>> [ 6260.517813] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1)=
 00:24:e8:a7:2c:42
>> [ 6260.517824] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Conn=
ection
>> [ 6260.518077] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 3002FF=
-0FF
>> [ 6260.518102] e1000e 0000:00:19.0: PME# enabled
>> [ 6260.556129] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6af=
ffff] (PCI address [0xf6ae0000-0xf6afffff])
>> [ 6260.556139] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6ad=
bfff] (PCI address [0xf6adb000-0xf6adbfff])
>> [ 6260.556147] e1000e 0000:00:19.0: BAR 2: set to [io =A00xefe0-0xefff] =
(PCI address [0xefe0-0xefff])
>> [ 6260.556167] e1000e 0000:00:19.0: restoring config space at offset 0xf=
 (was 0x100, writing 0x10a)
>> [ 6260.556193] e1000e 0000:00:19.0: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100107)
>> [ 6260.556253] e1000e 0000:00:19.0: PME# disabled
>> [ 6260.645141] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
>> [ 6260.700393] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
>> [ 6260.702222] ADDRCONF(NETDEV_UP): eth0: link is not ready
It doesn't have link.  Without link nothing can happen on the wire.
What are you expecting to happen here?

Have the device get link first.
-- =

Cheers,
John

---------------------------------------------------------------------------=
---
BlackBerry&reg; DevCon Americas, Oct. 18-20, San Francisco, CA
Learn about the latest advances in developing for the =

BlackBerry&reg; mobile platform with sessions, labs & more.
See new tools and technologies. Register for BlackBerry&reg; DevCon today!
http://p.sf.net/sfu/rim-devcon-copy1 =

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
