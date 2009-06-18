From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Thu, 18 Jun 2009 11:29:47 +0200
Message-ID: <4A3A090B.9020306@suse.de>
References: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, gospo@redhat.com, abjoglek@cisco.com,
	jeykholt@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Scott Feldman wrote:
> Consolidate shared code between enic and fnic drivers.
>=20
> [David/James, we need a little help with this one...this single patch
> spans scsi and netdev, so we're not sure which tree/maintainer needs
> to pick up the patch.  Please advise.  It's for 2.6.31.  The patch is
> against linux-2.6.git.]
>=20
Ah, finally. I was actually waiting someone would spot this ...

> The Cisco enic 10G Ethernet driver and the fnic FCoE HBA driver share
> much of the same hardware-access code because enic and fnic devices a=
re
> really two functions on a converged-I/O PCIe device.  This patch
> consolidates the shared code into one shared module, thus eliminating
> the code duplication.  No functional changes are made by the patch.
>=20
> Why weren't these consolidated in the first place?  fnic went in late=
 in
> 2.6.30 on the scsi branch (merge exception for new drivers), and it w=
as
> too late to modify enic which was already included in 2.6.28.
>=20
Hmm. Seeing that we're getting more and more of these type of drivers
(cf bnx2 / bnx2i / cnic, enic / fnic, and at least one other in the pip=
e)
one does wonder whether we should establish a separate directory for
these kind of things.
drivers/virtual or drivers/shared springs to mind.

Having them in the network directory is probably not the
correct choice.

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg
GF: Markus Rex, HRB 16746 (AG N=C3=BCrnberg)
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
