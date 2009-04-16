From: David Miller <davem@davemloft.net>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 16:00:02 -0700 (PDT)
Message-ID: <20090416.160002.09845606.davem@davemloft.net>
References: <49E78A79.6050604@cosmosbay.com>
	<49E78C1E.9060405@cosmosbay.com>
	<alpine.DEB.1.10.0904161555040.23632@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754022AbZDPXAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:00:11 -0400
In-Reply-To: <alpine.DEB.1.10.0904161555040.23632@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 16:01:16 -0400 (EDT)

> On Thu, 16 Apr 2009, Eric Dumazet wrote:
> 
>> Also you might check /proc/interrupts, because recent linux versions are
>> distributing interrupts on all cpus instead of one on previous version
> 
> Argh. I just checked it and the systems used for the test had no irq
> pinning. We are rerunning the series.

Good catch Eric :-)

We really need to find a good way to fix that IRQ affinity issue.
