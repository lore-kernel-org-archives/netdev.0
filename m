From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 12:27:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603301206390.13108@bizon.gios.gov.pl>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1041970610-1143714456=:13108"
Cc: nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, bb@kernelpanic.ru,
	mykleb@no.ibm.com, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1041970610-1143714456=:13108
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 29 Mar 2006, Brandeburg, Jesse wrote:

> Hi all, I've identified you as people who have at some point in the past
> emailed one of the Linux lists with problems with e1000 and
> sk_forward_alloc.  It seems to be fairly widespread, but only seems to
> have appeared with recent kernel changes (after 2.6.12...)
>
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?
RIOWORKS/PDRCA.

# lspci
00:00.0 Host bridge: ServerWorks GCNB-LE Host Bridge (rev 32)
00:00.1 Host bridge: ServerWorks GCNB-LE Host Bridge
00:02.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Con=
troller (rev 02)
00:04.0 I2O: Adaptec (formerly DPT) SmartRAID V Controller (rev 01)
00:04.1 PCI bridge: Adaptec (formerly DPT) PCI Bridge (rev 01)
00:06.0 Ethernet controller: D-Link System Inc DL2000-based Gigabit Etherne=
t (rev 0c)
00:08.0 SCSI storage controller: Initio Corporation INI-A100U2W (rev 01)
00:0e.0 IDE interface: ServerWorks CSB6 IDE Controller (rev a0)
00:0f.0 Host bridge: ServerWorks CSB6 South Bridge (rev a0)
00:0f.1 IDE interface: ServerWorks CSB6 RAID/IDE Controller (rev a0)
00:0f.2 USB Controller: ServerWorks CSB6 OHCI USB Controller (rev 05)
00:0f.3 ISA bridge: ServerWorks GCLE-2 Host Bridge

> What seems to cause this problem?
Don't known as this problem occurs only occasionally.

> Are you all using iptables?
Yes, this is a www proxy server with "-j REDIRECT".

>  Are you all routing?
Some kind as this is a transparent www proxy.

> From the reports I assume none of you are using an 82571/2/3 (pci=20
> express)


00:03.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Con=
troller (rev 02)
         Subsystem: Rioworks: Unknown device 3011
         Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 169
         Memory at d0000000 (32-bit, non-prefetchable) [size=3D128K]
         I/O ports at 2c00 [size=3D64]
         Capabilities: [dc] Power Management version 2
         Capabilities: [e4] PCI-X non-bridge device.
         Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=3D0/=
0 Enable-

Thank you.

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-1041970610-1143714456=:13108--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
