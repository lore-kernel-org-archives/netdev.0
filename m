From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Use consume_skb() to free gso segmented
 skb
Date: Tue, 30 Apr 2013 00:18:34 -0400 (EDT)
Message-ID: <20130430.001834.1391651112293759345.davem@davemloft.net>
References: <1367276562.23068.7.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab3D3ESg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 00:18:36 -0400
In-Reply-To: <1367276562.23068.7.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 29 Apr 2013 16:02:42 -0700

> Use consume_skb() to free the original skb that is successfully transmitted 
> as gso segmented skbs so that it is not treated as a drop due to an error.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
