From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup
Date: Fri, 15 Oct 2010 16:50:41 -0700
Message-ID: <20101015165041.6a9bb432@nehalam>
References: <20101015224309.179898823@vyatta.com>
	<20101015224523.633775810@vyatta.com>
	<1287185361.1117.734.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58069 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab0JOXup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 19:50:45 -0400
In-Reply-To: <1287185361.1117.734.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Oct 2010 16:29:21 -0700
Joe Perches <joe@perches.com> wrote:

> On Fri, 2010-10-15 at 15:43 -0700, Stephen Hemminger wrote:
> > plain text document attachment (cxgb4-local.patch)
> > Make functions only used in one file local.
> > Remove lots of dead code. Most surprising is the function
> > cxgb4_iscsi_init which is defined but never called!
> > Compile tested only
> 
> drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:1423:	cxgb4_iscsi_init(lldi->ports[0], tagmask, pgsz_factor);

Ok. drivers/scsi/cxgbi/cxgb4i does not exist in net-next
will recheck with linux-next
