From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [patch/RFC] networking menus
Date: Tue, 16 Mar 2004 12:01:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403161201.15427.ioe-lkml@rameria.de>
References: <20040314163327.53102f46.rddunlap@osdl.org> <20040314190724.1af1f11d.rddunlap@osdl.org> <20040314205438.3d7bcd34.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, niv@us.ibm.com,
        benh@kernel.crashing.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20040314205438.3d7bcd34.rddunlap@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

On Monday 15 March 2004 05:54, Randy.Dunlap wrote:
> Does it make sense to anyone besides me to move protocol-related
> modules like SLIP, PPP, and PLIP from Device Drivers/Network device(s)
> to "Networking support"?
> They feel more like protocols than device drivers to me....

Or just create sth. like:

Stacks
	+- IPv6
	+- LLC
	+- IrDA
	+- Bluetooth

Protocols
	+- PPP
	+- SLIP
	+- ...

Routing
	+- Multicast
	+- Advanced router

Filtering
Devices

Or similiar

Regards

Ingo Oeser

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAVt55U56oYWuOrkARAvGBAKCFh9DMVaKSlnj+X0CFuNFYgAc3CwCgv1vs
uet2gOmSQSwXJSo7hjpes2s=
=LfML
-----END PGP SIGNATURE-----
