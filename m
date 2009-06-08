From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Mon, 8 Jun 2009 10:59:34 -0700
Message-ID: <1244483974.9184.404.camel@HP1>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
 <1241208039-6813-4-git-send-email-mchan@broadcom.com>
 <1244483774.4079.368.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
To: "James Bottomley" <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3042 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbZFHSJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 14:09:32 -0400
In-Reply-To: <1244483774.4079.368.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-06-08 at 10:56 -0700, James Bottomley wrote:
> On Fri, 2009-05-01 at 13:00 -0700, Michael Chan wrote:
> > Add ISCSI_NETLINK messages to get/set vendor specific information.
> > This is to support bnx2i that handles net config of private iSCSI
> > IP address in userspace.
> > 
> > Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> This patch is rejecting pretty badly against both SCSI and net ... is
> there an update (I saw you updated the other three patches in this
> series on the 23rd, but not this one)?
> 

I believe this is an earlier version of the patch.  On the 23rd, I sent
a completely new version after feedback from Mike and Chelsio to
standardize the message format.  It was also re-ordered as patch 1/4.

We have some cleanups we want to make on the bnx2i patch (4/4).  I can
re-spin everything and send out the whole set of patches later today.

Thanks.

> James
> 
> ---
> 
> patching file drivers/scsi/scsi_transport_iscsi.c
> Hunk #1 succeeded at 1015 with fuzz 2 (offset 20 lines).
> Hunk #2 FAILED at 1416.
> Hunk #3 FAILED at 1456.
> Hunk #4 succeeded at 1611 with fuzz 2 (offset 80 lines).
> 2 out of 4 hunks FAILED -- saving rejects to file
> drivers/scsi/scsi_transport_iscsi.c.rej
> patching file include/scsi/iscsi_if.h
> Hunk #1 succeeded at 60 with fuzz 2 (offset 8 lines).
> Hunk #2 FAILED at 69.
> Hunk #3 FAILED at 165.
> Hunk #4 FAILED at 204.
> 3 out of 4 hunks FAILED -- saving rejects to file
> include/scsi/iscsi_if.h.rej
> patching file include/scsi/scsi_transport_iscsi.h
> Hunk #1 FAILED at 132.
> Hunk #2 succeeded at 151 with fuzz 2 (offset 2 lines).
> 1 out of 2 hunks FAILED -- saving rejects to file
> include/scsi/scsi_transport_iscsi.h.rej
> 
> 
> 


