From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Wed, 6 May 2009 09:42:24 -0700
Message-ID: <1241628144.10731.41.camel@HP1>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>
 <1241208039-6813-4-git-send-email-mchan@broadcom.com>
 <4A01BD96.60204@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
To: "Mike Christie" <michaelc@cs.wisc.edu>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A01BD96.60204@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2009-05-06 at 09:40 -0700, Mike Christie wrote:
> Michael Chan wrote:
> > Add ISCSI_NETLINK messages to get/set vendor specific information.
> > This is to support bnx2i that handles net config of private iSCSI
> > IP address in userspace.
> > 
> > Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > ---
> >  drivers/scsi/scsi_transport_iscsi.c |   59 ++++++++++++++++++++++++++++++++++-
> >  include/scsi/iscsi_if.h             |   14 ++++++++
> >  include/scsi/scsi_transport_iscsi.h |    6 +++
> >  3 files changed, 78 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
> > index 0947954..ef3af96 100644
> > --- a/drivers/scsi/scsi_transport_iscsi.c
> > +++ b/drivers/scsi/scsi_transport_iscsi.c
> > @@ -995,6 +995,37 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
> >  }
> >  EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
> >  
> > +extern int iscsi_vendor_priv_mesg(struct Scsi_Host *shost,
> 
> Just a cut and paste error probably. You have an extern in there.

Thanks for noticing.  Will fix this up in the next version of the patch.

> 
> > +				  struct iscsi_transport *transport,
> > +				  uint16_t priv_op,
> > +				  char *data, uint16_t data_size)
> > +{
> 
> 


