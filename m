From: Varun Prakash <varun@chelsio.com>
Subject: Re: [net-next 2/6] cxgb3i,cxgb4i,libcxgbi: remove iSCSI DDP support
Date: Sat, 16 Jul 2016 21:14:28 +0530
Message-ID: <20160716154426.GA1653@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
 <73c3770a7b69e10c80b3f3a690c5819f735b1a28.1467998292.git.varun@chelsio.com>
 <099301d1dea1$f36ec980$da4c5c80$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"james.bottomley@hansenpartnership.com"
	<james.bottomley@hansenpartnership.com>,
	Indranil Choudhury <indranil@chelsio.com>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <099301d1dea1$f36ec980$da4c5c80$@opengridcomputing.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2016 at 07:35:32PM +0530, Steve Wise wrote:
> > Remove old ddp code from cxgb3i,cxgb4i,libcxgbi.
> > 
> > Next two commits adds DDP support using
> > common iSCSI DDP Page Pod Manager.
> > 
> > Signed-off-by: Varun Prakash <varun@chelsio.com>
> > ---
> >  drivers/scsi/cxgbi/cxgb3i/cxgb3i.c | 128 --------
> >  drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 142 ---------
> >  drivers/scsi/cxgbi/libcxgbi.c      | 578
> -------------------------------------
> >  drivers/scsi/cxgbi/libcxgbi.h      | 161 -----------
> >  4 files changed, 1009 deletions(-)
> 
> Looks good.  I guess this series needs to be squashed or we'll have bisect
> compile problems?

All cxgb* drivers compiles successfully after applying
patches incrementally. 
