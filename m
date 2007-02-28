From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4]: Store retransmit queue packets in RB tree.
Date: Wed, 28 Feb 2007 12:56:19 -0800 (PST)
Message-ID: <20070228.125619.74747682.davem@davemloft.net>
References: <20070228.114912.89063615.davem@davemloft.net>
	<45E5E72E.6070109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbXB1U4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 15:56:20 -0500
In-Reply-To: <45E5E72E.6070109@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 28 Feb 2007 21:33:50 +0100

> I am not sure this rb_node placement is optimal. rb lookups want to access 
> rb_node and end_seq. They should be placed in the same cache line :)

Definitely an area for improvement for sure, but that's not
the are of focus of these changes at this point :-)
