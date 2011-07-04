From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-next PATCH 1/2] dcbnl: Aggregated CEE GET operation
Date: Mon, 4 Jul 2011 21:22:34 +0300
Message-ID: <1309803754.9038.9.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <1309624423.15528.43.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4E10B03C.1070803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1898 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757667Ab1GDQdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 12:33:50 -0400
In-Reply-To: <4E10B03C.1070803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2011-07-03 at 11:09 -0700, John Fastabend wrote:
> >  
> > +static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
> > +			     int dir)
> 
> Why the 'dir'? Could you just pack both tx and rx together? It looks like all
> cases pack TX then pack RX. Did I miss something?
> 
This is just an auxiliary function meant to avoid duplicating the loops
that build the DCB_ATTR_CEE_TX_PG and DCB_ATTR_CEE_RX_PG nested
attributes. The only differences are the parent attribute and the driver
callbacks. Its similar to the way  dcbnl_pgtx_getcfg() and
dcbnl_pgrx_getcfg() are already implemented.

I'll incorporate the other comments to a v2 version of the patch.

Thanks,
Shmulik



