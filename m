From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Mon, 08 Jun 2009 18:13:34 +0000
Message-ID: <1244484814.4079.390.camel@mulgrave.site>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
	 <1241208039-6813-4-git-send-email-mchan@broadcom.com>
	 <1244483774.4079.368.camel@mulgrave.site>  <1244483974.9184.404.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1244483974.9184.404.camel@HP1>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-08 at 10:59 -0700, Michael Chan wrote:
> On Mon, 2009-06-08 at 10:56 -0700, James Bottomley wrote:
> > On Fri, 2009-05-01 at 13:00 -0700, Michael Chan wrote:
> > > Add ISCSI_NETLINK messages to get/set vendor specific information.
> > > This is to support bnx2i that handles net config of private iSCSI
> > > IP address in userspace.
> > > 
> > > Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
> > > Acked-by: David S. Miller <davem@davemloft.net>
> > 
> > This patch is rejecting pretty badly against both SCSI and net ... is
> > there an update (I saw you updated the other three patches in this
> > series on the 23rd, but not this one)?
> > 
> 
> I believe this is an earlier version of the patch.  On the 23rd, I sent
> a completely new version after feedback from Mike and Chelsio to
> standardize the message format.  It was also re-ordered as patch 1/4.
> 
> We have some cleanups we want to make on the bnx2i patch (4/4).  I can
> re-spin everything and send out the whole set of patches later today.

That's probably the best solution ... I found it ... I'd just got the
old patch labelled in my workflow somehow.

Thanks,

James


