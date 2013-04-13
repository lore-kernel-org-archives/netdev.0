From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 10:10:24 -0700
Message-ID: <1365873024.2358.7.camel@joe-AO722>
References: <1365871134-6834-1-git-send-email-festevam@gmail.com>
	 <1365871779.2358.3.camel@joe-AO722>
	 <CAOMZO5DfOXxZ5pgvgxgaKXgP0_XMvrfTUdMqMhMDFPLb4ZtsVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48151 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753494Ab3DMRKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:10:24 -0400
In-Reply-To: <CAOMZO5DfOXxZ5pgvgxgaKXgP0_XMvrfTUdMqMhMDFPLb4ZtsVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-13 at 13:54 -0300, Fabio Estevam wrote:
> On Sat, Apr 13, 2013 at 1:49 PM, Joe Perches <joe@perches.com> wrote:
> 
> > Maybe better as:
> >                 netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);
> 
> In this case I get:
> 
> fec 2188000.ethernet (unregistered net_device): registered PHC device 0

Everything in fec_probe between the alloc_etherdev
and register_netdev would get that, but the actual
registered netdev name perhaps is not guaranteed to
be fep->dev_id.
