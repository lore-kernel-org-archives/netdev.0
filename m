From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 5/5] ethernet: Use pci_(request|release)_mem_regions
Date: Wed, 1 Jun 2016 10:51:12 +0200
Message-ID: <20160601085112.ve6k7bzspapjsswf@c203.arch.suse.de>
References: <cover.1464694724.git.jthumshirn@suse.de>
 <3f24b687c31dea31a03cd3a529de790e942dd5bb.1464694724.git.jthumshirn@suse.de>
 <20160601075956.GD11923@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160601075956.GD11923@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 12:59:56AM -0700, Christoph Hellwig wrote:
> On Tue, May 31, 2016 at 02:05:13PM +0200, Johannes Thumshirn wrote:
> > Now that we do have pci_request_mem_regions() and pci_release_mem_r=
egions() at
> > hand, use it in the ethernet drivers.
>=20
> This should probably be one patch per driver.

I though if I do one patch per subsystem it'll be less a hassle for the
individual maintainers, but if the netdev people want it as split up, I=
'll be
doing it of cause.

	Johannes
--=20
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=FCrnberg)
Key fingerprint =3D EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
