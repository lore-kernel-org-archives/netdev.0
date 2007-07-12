From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 13:24:48 -0700 (PDT)
Message-ID: <20070712.132448.115910193.davem@davemloft.net>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
	<20070712.023710.36923635.davem@davemloft.net>
	<20070712.225950.12335719.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755744AbXGLUes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 16:34:48 -0400
In-Reply-To: <20070712.225950.12335719.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Date: Thu, 12 Jul 2007 22:59:50 +0900 (JST)

> How do you think TCP timeouts in Linux can adapt to such changes
> in network environment?

I'm honestly not interested in discussing this any more
and Ian has even showed that the RFCs state that if we have
a maximum it must be at least 60.

So really, there is no chance of merging a TCP_RTO_MAX
decreasing patch, sorry.
