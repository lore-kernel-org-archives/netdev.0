From: Varun Prakash <varun@chelsio.com>
Subject: Re: [net-next 3/6] cxgb4i,libcxgbi: add iSCSI DDP support
Date: Sat, 16 Jul 2016 21:24:06 +0530
Message-ID: <20160716155405.GB1653@chelsio.com>
References: <cover.1467998292.git.varun@chelsio.com>
 <81194c2febf45634eea991621d6522886c495065.1467998293.git.varun@chelsio.com>
 <099501d1dea3$04818e50$0d84aaf0$@opengridcomputing.com>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <099501d1dea3$04818e50$0d84aaf0$@opengridcomputing.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2016 at 07:43:10PM +0530, Steve Wise wrote:
> > Add iSCSI DDP support in cxgb4i driver
> > using common iSCSI DDP Page Pod Manager.
> > 
> > Signed-off-by: Varun Prakash <varun@chelsio.com>
> > ---
> >  drivers/scsi/cxgbi/Makefile        |   2 +
> >  drivers/scsi/cxgbi/cxgb3i/Kbuild   |   1 +
> >  drivers/scsi/cxgbi/cxgb3i/Kconfig  |   1 +
> 
> Should the cxgb3i changes be in patch 4?

Both cxgb3i and cxgb4i depends on libcxgbi, this
patch adds DDP code in libcxgbi, to compile
cxgb3i Kconfig and Kbuild update is required in
this patch.

> 
> >  drivers/scsi/cxgbi/cxgb4i/Kbuild   |   1 +
> >  drivers/scsi/cxgbi/cxgb4i/Kconfig  |   1 +
> >  drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 145 ++++++++++++++++
> >  drivers/scsi/cxgbi/libcxgbi.c      | 331
> +++++++++++++++++++++++++++++++++++++
> >  drivers/scsi/cxgbi/libcxgbi.h      |  27 ++-
> >  8 files changed, 507 insertions(+), 2 deletions(-)
> > 
