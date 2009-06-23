From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Tue, 23 Jun 2009 14:02:02 -0700
Message-ID: <ada4ou6pstx.fsf@cisco.com>
References: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
	<4A3A090B.9020306@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, gospo@redhat.com, abjoglek@cisco.com,
	jeykholt@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A3A090B.9020306@suse.de> (Hannes Reinecke's message of "Thu, 18
	Jun 2009 11:29:47 +0200")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > Hmm. Seeing that we're getting more and more of these type of drivers
 > (cf bnx2 / bnx2i / cnic, enic / fnic, and at least one other in the pipe)
 > one does wonder whether we should establish a separate directory for
 > these kind of things.
 > drivers/virtual or drivers/shared springs to mind.
 > 
 > Having them in the network directory is probably not the
 > correct choice.

Good idea.  Maybe I'll post a patch to do that, since one of the drivers
I maintain (mlx4) has a similar structure.

 - R.
