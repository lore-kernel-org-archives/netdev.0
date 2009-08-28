From: David Miller <davem@davemloft.net>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 13:03:09 -0700 (PDT)
Message-ID: <20090828.130309.225603635.davem@davemloft.net>
References: <alpine.DEB.1.10.0908280948320.3747@gentwo.org>
	<20090828.122459.245170385.davem@davemloft.net>
	<alpine.DEB.1.10.0908281553190.17784@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752263AbZH1UC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:02:56 -0400
In-Reply-To: <alpine.DEB.1.10.0908281553190.17784@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 28 Aug 2009 15:53:42 -0400 (EDT)

> On Fri, 28 Aug 2009, David Miller wrote:
> 
>> If you start incrementing tx_dropped here, people won't be able
>> to tell they have a deteriorating cable or bad switch or similar.
> 
> ?? The patch does not do that. That was extra stuff not covered by the
> patch.

Yes you did, you put a device tx_dropped counter bump into
qdisc_drop().
