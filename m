From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH v3 0/6] Introduce pci_(request|release)_(mem|io)_regions
Date: Wed, 8 Jun 2016 09:28:54 +0200
Message-ID: <20160608072854.ivcfvtlgxab2xkmp@c203.arch.suse.de>
References: <cover.1465200424.git.jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>,
	linux-nvme@lists.infradead.org,
	James Smart <james.smart@avagotech.com>,
	Dick Kennedy <dick.kennedy@avagotech.com>,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	linux-scsi@vger.kernel.org,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1465200424.git.jthumshirn@suse.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 07, 2016 at 09:44:00AM +0200, Johannes Thumshirn wrote:
> The first patch in this series introduces the following 4 helper func=
tions to
> the PCI core:
>=20
> * pci_request_mem_regions()
> * pci_request_io_regions()
> * pci_release_mem_regions()
> * pci_release_io_regions()
>=20
> which encapsulate the request and release of a PCI device's memory or=
 I/O
> bars.
>=20
> The subsequent patches convert the drivers, which use the
> pci_request_selected_regions(pdev,=20
> 	pci_select_bars(pdev, IORESOURCE_MEM), name);=20
> and similar pattern to use the new interface.
>=20
> This was suggested by Christoph Hellwig in
> http://lists.infradead.org/pipermail/linux-nvme/2016-May/004570.html =
and
> tested on kernel v4.6 with NVMe.
>=20

Btw, as I've seen already Jeff applying the Intel Ethernet patch to his
tree, I think this should go via the PCI tree as the build dependency i=
s
the PCI patch.

Thanks,
	Johannes
--=20
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=FCrnberg)
Key fingerprint =3D EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
