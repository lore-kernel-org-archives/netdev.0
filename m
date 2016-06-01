From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 5/5] ethernet: Use pci_(request|release)_mem_regions
Date: Wed, 1 Jun 2016 17:26:40 +0200
Message-ID: <20160601152640.tzhn5itms73q5fbw@c203.arch.suse.de>
References: <cover.1464694724.git.jthumshirn@suse.de>
 <3f24b687c31dea31a03cd3a529de790e942dd5bb.1464694724.git.jthumshirn@suse.de>
 <20160601075956.GD11923@infradead.org>
 <20160601085112.ve6k7bzspapjsswf@c203.arch.suse.de>
 <1464793005.2960.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464793005.2960.3.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 07:56:45AM -0700, Jeff Kirsher wrote:
> On Wed, 2016-06-01 at 10:51 +0200, Johannes Thumshirn wrote:
> > On Wed, Jun 01, 2016 at 12:59:56AM -0700, Christoph Hellwig wrote:
> > > On Tue, May 31, 2016 at 02:05:13PM +0200, Johannes Thumshirn wrot=
e:
> > > > Now that we do have pci_request_mem_regions() and
> > pci_release_mem_regions() at
> > > > hand, use it in the ethernet drivers.
> > >=A0
> > > This should probably be one patch per driver.
> >=20
> > I though if I do one patch per subsystem it'll be less a hassle for=
 the
> > individual maintainers, but if the netdev people want it as split u=
p,
> > I'll be
> > doing it of cause.
>=20
> Since almost all the changes are to Intel wired LAN drivers, if you j=
ust
> split off the atheros change into a separate patch, I would be happy.=
 =A0Then
> you could keep just one patch to change all the Intel drivers.

That should be doable. I'll send a v2 with all requested changes tomorr=
ow.

--=20
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=FCrnberg)
Key fingerprint =3D EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
