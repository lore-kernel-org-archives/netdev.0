From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Sun, 09 Jul 2006 18:34:51 +0200
Message-ID: <44B1302B.5060207@better.se>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se> <44AFDA3B.6020904@tungstengraphics.com> <44B0AED8.3040604@better.se> <44B0B17D.10803@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net,
	Alan Hourihane <alanh@tungstengraphics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep01.bredband.com ([195.54.107.70]:51899 "EHLO
	mxfep01.bredband.com") by vger.kernel.org with ESMTP
	id S1751327AbWGIQfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 12:35:01 -0400
To: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
In-Reply-To: <44B0B17D.10803@tungstengraphics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Thomas Hellstr=F6m wrote:
> Strange. I've also seen the i915 sending false interrupts on its own
> line, though.

Here's the interrupt table with i915 loaded:

~$ cat /proc/interrupts
           CPU0
  0:     401031          XT-PIC  timer
  1:       3681          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  8:          0          XT-PIC  rtc
  9:          0          XT-PIC  acpi
 10:        997          XT-PIC  yenta, Intel 82801CA-ICH3, Intel
82801CA-ICH3 Modem
 11:      93823          XT-PIC  uhci_hcd:usb1, uhci_hcd:usb2, eth0,
i915@pci:0000:00:02.0
 12:      75631          XT-PIC  i8042
 14:      18284          XT-PIC  ide0
 15:      13901          XT-PIC  ide1
NMI:          0
ERR:          0

> Does the "noirqdebug" option fix the problem?

Yes, it appears to fix it.

Marcus

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEsTArXjXn6TzcAQkRAn/vAKCZUAVd45xQae4FthvNr68x/jTS4QCgyE7N
CzPv0R9okmIjrsGykMXrfPk=3D
=3DgU6D
-----END PGP SIGNATURE-----
