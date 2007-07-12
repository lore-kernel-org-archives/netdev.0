From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 14:12:03 -0700
Message-ID: <20070712141203.7350429a@freepuppy.rosehill.hemminger.net>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
	<20070712.023710.36923635.davem@davemloft.net>
	<20070712.225950.12335719.noboru.obata.ar@hitachi.com>
	<20070712.132448.115910193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56916 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935321AbXGLVMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 17:12:20 -0400
In-Reply-To: <20070712.132448.115910193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 13:24:48 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> Date: Thu, 12 Jul 2007 22:59:50 +0900 (JST)
> 
> > How do you think TCP timeouts in Linux can adapt to such changes
> > in network environment?
> 
> I'm honestly not interested in discussing this any more
> and Ian has even showed that the RFCs state that if we have
> a maximum it must be at least 60.
> 
> So really, there is no chance of merging a TCP_RTO_MAX
> decreasing patch, sorry.

One question is why the RTO gets so large that it limits failover?

If Linux TCP is working correctly,  RTO should be srtt + 2*rttvar

So either there is a huge srtt or variance, or something is going
wrong with RTT estimation.  Given some reasonable maximums of
Srtt = 500ms and rttvar = 250ms, that would cause RTO to be 1second.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
