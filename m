From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 00/11] Add support to FCoE offload through net_device
	(v2)
Date: Thu, 05 Mar 2009 21:59:20 +0000
Message-ID: <1236290360.5626.81.camel@localhost.localdomain>
References: <20090227220034.4987.50755.stgit.yi.zou@intel.com>
	 <20090303.235725.140764281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090303.235725.140764281.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-03-03 at 23:57 -0800, David Miller wrote:
> From: Yi Zou <yi.zou@intel.com>
> Date: Fri, 27 Feb 2009 14:06:32 -0800
> 
> > This is set of revised patches for adding offload support of
> > Fiber Channel over Ethernet (FCoE) offload support through net_device
> > for the Open-FCoE project maintained at http://www.open-fcoe.org.
> > 
> > The original submission can be found at:
> > http://marc.info/?l=linux-scsi&m=123507707821705&w=2
> > 
> > The included patches would add FCoE offload support through the net_device
> > struct as shown in the series of patches followed here. This is achieved
> > by adding nedev feature flags for FCoE FC CRC offload and large send offload
> > through gso. The large receive offload by direct data placement (ddp) is
> > achieved by the two function pointers to net_device_ops, to setup and release
> > ddp context, ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done. One data member is
> > added to net_device strut, namely fcoe_ddp_xid, which inidates the maximum
> > exchange id allowed by LLD to perform ddp on the read I/O request.
> > 
> > As the following patches touch both netdev and libfc/fcoe, and they are
> > applicable to the current tip at www.open-fcoe.org w/ patches available at:
> > http://marc.info/?l=linux-scsi&m=123576089125544&w=2 If they look alright,
> > I will rework them later to be directly applicable to net-next, where the
> > aforementioned fcoe/libfc fix patches are expected to be in kernel already
> > through scsi-fixes.
> 
> I am fine with these changes, they look good.

Did you want to take the four pure net pieces through your tree, and
I'll run a postmerge tree based on your net tree, or just have me take
them through the SCSI tree?

James


