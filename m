From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next,v2,1/1] hv_netvsc: introduce netif-msg into
 netvsc module
Date: Fri, 24 Apr 2015 15:59:29 -0700
Message-ID: <1429916369.23327.29.camel@perches.com>
References: <1429900488-7302-1-git-send-email-sixiao@microsoft.com>
	 <1429907357.23327.14.camel@perches.com>
	 <CY1PR03MB137688C6CC69DBFC097F6031C4EC0@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Simon Xiao <sixiao@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0165.hostedemail.com ([216.40.44.165]:52969 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756343AbbDXW7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 18:59:33 -0400
In-Reply-To: <CY1PR03MB137688C6CC69DBFC097F6031C4EC0@CY1PR03MB1376.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-24 at 22:52 +0000, Simon Xiao wrote:
> > From: Joe Perches [mailto:joe@perches.com]
> > On Fri, 2015-04-24 at 11:34 -0700, sixiao@microsoft.com wrote:
> > > From: Simon Xiao <sixiao@microsoft.com>
> > >
> > > 1. Introduce netif-msg to netvsc to control debug logging output and
> > > keep msg_enable in netvsc_device_context so that it is kept
> > > persistently.
[]
> > > diff --git a/drivers/net/hyperv/netvsc_drv.c
[]
> > > +	if (netif_msg_probe(net_device_ctx))
> > > +		netdev_dbg(net, "netvsc msg_enable: %d",
> > > +			   net_device_ctx->msg_enable);
> > 
> > Please use newlines to terminate formats.
> > 
> > It helps prevent log content interleaving when multiple processes are
> > emitting output at the same time.
> > 
> > This could be shortened to use netif_<level> like:
> > 
> > 	netif_dbg(net_device_ctx, probe, net, "netvsc_msg_enable: %d\n",
> > 		  net_device_ctx->msg_enable);
> > 
> 
> Thanks Joe. I would like to leave this to my next patch as there are some places else in netvsc (rndis_filter.c) 
> have the same usage. I would like to fix them in one patch to make them consistent.

Oh sure no worries.

It is nicer though to not introduce new formats
with missing newline defects.

cheers, Joe
