From: David Miller <davem@davemloft.net>
Subject: Re: Use correct NET_RX_* returns for atalk_rcv()
Date: Wed, 12 Aug 2009 22:15:50 -0700 (PDT)
Message-ID: <20090812.221550.173145055.davem@davemloft.net>
References: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbZHMFPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:15:40 -0400
In-Reply-To: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Fri, 7 Aug 2009 18:51:22 +0930

> 
>     In all rx'd SKB cases, atalk_rcv() either eventually jumps to or falls through
>     to the label out:, which  returns numeric 0. Numeric 0 corresponds to
>     NET_RX_SUCCESS, which is incorrect in failed SKB cases.
>     
>     This patch makes atalk_rcv() provide the correct returns by:
>     
>     o  explicitly returning NET_RX_SUCCESS in the two success cases
>     o  having the out: label return NET_RX_DROP, instead of numeric 0
>     o  making the failed SKB labels and processing more consistent with other
>        _rcv() routines in the kernel, simplifying validation and removing a
>        backwards goto
> 
> Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

Applied.
