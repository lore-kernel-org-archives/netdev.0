From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Tue, 23 Jun 2009 13:58:10 -0700
Message-ID: <ada8wjipt0d.fsf@cisco.com>
References: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, gospo@redhat.com, abjoglek@cisco.com,
	jeykholt@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Wed, 17 Jun 2009 22:05:04 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > The Cisco enic 10G Ethernet driver and the fnic FCoE HBA driver share
 > much of the same hardware-access code because enic and fnic devices are
 > really two functions on a converged-I/O PCIe device.  This patch
 > consolidates the shared code into one shared module, thus eliminating
 > the code duplication.  No functional changes are made by the patch.

Big ACK on this from me -- I never liked duplicating all this code
between the two drivers.

 - R.
