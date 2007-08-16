From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Thu, 16 Aug 2007 10:46:35 +0200
Message-ID: <20070816084635.GA15985@osiris.boeblingen.de.ibm.com>
References: <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Paul Mundt <lethal@linux-sh.org>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	netdev@vger.kernel.org, swen@vnet.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, jdike@karaya.com,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:55631 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbXHPIrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 04:47:02 -0400
Content-Disposition: inline
In-Reply-To: <1187224811.5906.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 05:40:11PM -0700, Joe Perches wrote:
> On Wed, 2007-08-15 at 19:58 -0400, Dave Jones wrote:
> > Signed-off-by: Dave Jones <davej@redhat.com>
> > 
> > diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
> > index 3330917..0ed02b7 100644
> > --- a/drivers/infiniband/hw/mlx4/mad.c
> > +++ b/drivers/infiniband/hw/mlx4/mad.c
> > @@ -109,7 +109,7 @@ int mlx4_MAD_IFC(struct mlx4_ib_dev *dev, int ignore_mkey, int ignore_bkey,
> >  			   in_modifier, op_modifier,
> >  			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C);
> >  
> > -	if (!err);
> > +	if (!err)
> 
> There's more than a few of these (not inspected).
> 
> $ egrep -r --include=*.c "\bif[[:space:]]*\([^\)]*\)[[:space:]]*\;" * 

[...]

> drivers/s390/scsi/zfcp_erp.c:           if (status == ZFCP_ERP_SUCCEEDED) ;     /* no further action */

At least this one is not a bug. But I'm going to add a "break" there, so it
doesn't look that strange anymore. Thanks!
