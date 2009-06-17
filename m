From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: dma-debug warning with ixgbe
Date: Wed, 17 Jun 2009 11:26:29 +0200
Message-ID: <20090617092629.GP5139@amd.com>
References: <20090616153417.GN5139@amd.com> <alpine.WNT.2.00.0906160907580.6076@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:8502 "EHLO
	TX2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZFQJ0l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 05:26:41 -0400
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.0906160907580.6076@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 09:33:15AM -0700, Brandeburg, Jesse wrote:
> On Tue, 16 Jun 2009, Joerg Roedel wrote:
> > today I got this dma-debug warning with the ixgbe driver with a ker=
nel
> > near 2.6.30-rc8.
>=20
> Hi Joerg, thanks for the report, I thought we had fixed all of these=20
> already but we must have missed this one.
>=20
> > ------------[ cut here ]------------
> > WARNING: at /data/repos/linux-2.6-iommu/lib/dma-debug.c:806
> > check_unmap+0x214/0x5c3()
> > Hardware name: Toonie
> > ixgbe 0000:02:00.0: DMA-API: device driver frees DMA memory with
> > different size [device address=3D0x0000000000045c12] [map size=3D25=
8
> > bytes] [unmap size=3D256 bytes]
>=20
> The following patch should fix it, compile tested only, but it is pre=
tty=20
> straight forward.

Thanks for the quick answer :) But I tested the patch and the warning i=
s
still there.

	Joerg

--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=FCnchen
 System    |=20
 Research  | Gesch=E4ftsf=FChrer: Thomas M. McCoy, Giuliano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=FCnchen
           | Registergericht M=FCnchen, HRB Nr. 43632

