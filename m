From: Bill Fink <billfink@mindspring.com>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 9 May 2008 22:20:06 -0400
Message-ID: <20080509222006.6a43e740.billfink@mindspring.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
	<20080507.141521.193714938.davem@davemloft.net>
	<482498D5.9060008@krogh.cc>
	<20080509.143229.174354251.davem@davemloft.net>
	<4824C936.9000103@krogh.cc>
	<4824CE43.8060203@hp.com>
	<4824D4C0.10201@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:39637 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751800AbYEJCUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 22:20:20 -0400
In-Reply-To: <4824D4C0.10201@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 May 2008, Jesper Krogh wrote:

> Rick Jones wrote:
> > 
> > Into which slot was the Neptune inserted?  (sure will be nice to have 
> > Alex Chiang's pci slot id patch in mainline one of these days :)
> > 
> > Is that slot x4, x8, x16?
> 
> I can find out excactly .. on monday. But shouldn't x4 be enough anyway?
> wikipedia says 250MB/s pr. lane. And no slots is less than x4, so I
> thought that it didn't matter to me.

No you need 8x for 10-GigE.  The 250 MB/sec per lane is 2 Gbps per lane
so 4x is only 8 Gbps.  For a typical PCI-E transaction size of 128 bytes,
and PCI-E protocol overhead of 20 to 24 bytes, that takes off about 20%,
which leaves you with about 6.5 Gbps of usable bandwidth, which is further
reduced somewhat by the required PCI-E ACK and flow control packets that
accompany the actual data transaction packets.  I am not an expert on
PCI-E but I believe this info to be generally correct.

						-Bill
