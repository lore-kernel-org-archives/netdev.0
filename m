From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] virtio_net: Set vlan_features to enable
 offloads on vlan devices
Date: Tue, 02 Feb 2010 07:46:52 -0800 (PST)
Message-ID: <20100202.074652.112999481.davem@davemloft.net>
References: <1264454176.28852.129.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750835Ab0BBPqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:46:38 -0500
In-Reply-To: <1264454176.28852.129.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 25 Jan 2010 13:16:16 -0800

> Set vlan_features in virtnet_probe() so that all the available offloads
> are enabled on vlan devices attached to virtio_net devices.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

I can't apply this because I'm not going to apply your
patch which erroneously pops the VLAN header during GRO
processing.  And this patch is useless without that.

