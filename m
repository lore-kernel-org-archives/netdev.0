From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup
Date: Fri, 15 Oct 2010 16:29:21 -0700
Message-ID: <1287185361.1117.734.camel@Joe-Laptop>
References: <20101015224309.179898823@vyatta.com>
	 <20101015224523.633775810@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2977 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab0JOX3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 19:29:24 -0400
In-Reply-To: <20101015224523.633775810@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-15 at 15:43 -0700, Stephen Hemminger wrote:
> plain text document attachment (cxgb4-local.patch)
> Make functions only used in one file local.
> Remove lots of dead code. Most surprising is the function
> cxgb4_iscsi_init which is defined but never called!
> Compile tested only

drivers/scsi/cxgbi/cxgb4i/cxgb4i.c:1423:	cxgb4_iscsi_init(lldi->ports[0], tagmask, pgsz_factor);



