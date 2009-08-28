From: David Miller <davem@davemloft.net>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 13:04:26 -0700 (PDT)
Message-ID: <20090828.130426.180763121.davem@davemloft.net>
References: <alpine.DEB.1.10.0908281211150.7317@gentwo.org>
	<20090828.122658.188210079.davem@davemloft.net>
	<alpine.DEB.1.10.0908281556480.17784@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbZH1UEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:04:12 -0400
In-Reply-To: <alpine.DEB.1.10.0908281556480.17784@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 28 Aug 2009 16:00:24 -0400 (EDT)

> Are you saying that this behavior is okay? It is desired behavior that a
> socket option changes the way how global network counters are handled?

I'm saying that bumping the per-device tx_dropped counter in
the qdisc layer is wrong, nothing more.
