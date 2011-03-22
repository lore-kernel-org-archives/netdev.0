From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] ipv4: optimize route adding on secondary
 promotion
Date: Tue, 22 Mar 2011 01:07:50 -0700 (PDT)
Message-ID: <20110322.010750.91334050.davem@davemloft.net>
References: <201103192213.p2JMDs0S003092@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755276Ab1CVIHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:07:12 -0400
In-Reply-To: <201103192213.p2JMDs0S003092@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 20 Mar 2011 00:13:54 +0200

> 	Optimize the calling of fib_add_ifaddr for all
> secondary addresses after the promoted one to start from
> their place, not from the new place of the promoted
> secondary. It will save some CPU cycles because we
> are sure the promoted secondary was first for the subnet
> and all next secondaries do not change their place.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
