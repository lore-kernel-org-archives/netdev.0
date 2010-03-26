From: =?utf-8?Q?J=F6rn?= Engel <joern@dublin.logfs.org>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI
	Express devices (v2)
Date: Fri, 26 Mar 2010 10:12:34 +0100
Message-ID: <20100326091234.GA11959@Dublin.logfs.org>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com> <20100316083501.GA3489@Dublin.logfs.org> <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com> <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 March 2010 18:56:03 -0600, Robert Hancock wrote:
>=20
> Francois, ping? Is there anyone else that has access to this kind of
> information about these chips?
>=20
> It's kind of interesting that there's only been one report of this
> though. Either the affected chips are rare among people testing
> 2.6.34-rc or there's something more to this. Maybe something
> wierd/unusual about J=C3=B6rn's system?
>=20
> J=C3=B6rn, are any other devices on your system working with 64-bit
> addressing? Try doing this:
>=20
> find /sys -name "*dma_mask_bits*" | xargs cat
>=20
> Does anything show more than 32?

I've slightly changed the command:
# for i in `find /sys -name "*dma_mask_bits*"`; do echo -n "$i: "; cat =
$i; done
/sys/devices/pci0000:00/0000:00:00.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:00.0/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:02.0/dma_mask_bits: 36
/sys/devices/pci0000:00/0000:00:02.0/consistent_dma_mask_bits: 36
/sys/devices/pci0000:00/0000:00:1c.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1c.0/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1c.1/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1c.1/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1c.1/0000:01:00.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1c.1/0000:01:00.0/consistent_dma_mask_b=
its: 32
/sys/devices/pci0000:00/0000:00:1d.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.0/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.1/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.1/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.2/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.2/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.3/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.3/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.7/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1d.7/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1e.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1e.0/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.0/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.0/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.1/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.1/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.2/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.2/consistent_dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.3/dma_mask_bits: 32
/sys/devices/pci0000:00/0000:00:1f.3/consistent_dma_mask_bits: 32

One device, which should be this one:
00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Express =
Integrated Graphics Controller (rev 10)

J=EF=BF=BDrn
