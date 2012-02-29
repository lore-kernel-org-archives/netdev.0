From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH v4 1/2] netdev: driver: ethernet: add cpsw address
 lookup engine support
Date: Wed, 29 Feb 2012 15:27:32 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293179370C@DBDE01.ent.ti.com>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	 <1330490737-28973-2-git-send-email-mugunthanvnm@ti.com>
 <1330490933.4352.1.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34496 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031111Ab2B2P1k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 10:27:40 -0500
In-Reply-To: <1330490933.4352.1.camel@joe2Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, February 29, 2012 10:19 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH v4 1/2] netdev: driver: ethernet: add cpsw address
> lookup engine support
> 
> On Wed, 2012-02-29 at 10:15 +0530, Mugunthan V N wrote:
> > TI CPSW ethernet switch has a built-in address lookup engine.  This
> patch adds
> > the code necessary for programming this module.
> []
> >  drivers/net/ethernet/ti/cpsw_ale.c |  638
> ++++++++++++++++++++++++++++++++++++
> []
> > +struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
> > +{
> > +	struct cpsw_ale *ale;
> > +
> > +	ale = kzalloc(sizeof(*ale), GFP_KERNEL);
> > +	ale->params = *params;
> 
> kzalloc failure...
> 
Will take care of the kzalloc failures in next set of patches.

With regards
Mugunthan V N
