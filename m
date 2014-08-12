From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to pass
 tcp_tw_recycle logic
Date: Tue, 12 Aug 2014 10:08:42 +0200
Message-ID: <1407830922.3313272.151751729.150ABE1E@webmail.messagingengine.com>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
 <20140811.200807.1174604291924802129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:40142 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162AbaHLIIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 04:08:43 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway1.nyi.internal (Postfix) with ESMTP id F131F22B2B
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 04:08:42 -0400 (EDT)
In-Reply-To: <20140811.200807.1174604291924802129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Aug 12, 2014, at 05:08, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 12 Aug 2014 02:21:36 +0200
> 
> > Thus this broken situation could easily arise by a Linux and Windows
> > box sharing one IP address and talking to a tcp_tw_recycle enabled
> > server.
> 
> As Eric Dumazet mentioned, timewait recycling does not work if any
> traffic goes through a NAT box.
> 
> So this situation of two boxes "sharing one IP address" fundamentally
> makes timewait recycling unusable.

Exactly, I'll just throw away the SYN packet instead of opening a
connection where we couldn't very if the preconditions for timewait
recycling did not hold.

Bye,
Hannes
