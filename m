From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v1] net: filter: Just In Time compiler
Date: Sun, 3 Apr 2011 00:50:02 +0200
Message-ID: <20110402225002.GJ3108@nuttenaction>
References: <1301783301.2837.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38472 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753017Ab1DBWuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 18:50:05 -0400
Content-Disposition: inline
In-Reply-To: <1301783301.2837.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-04-03 00:28:21 [+0200]:

>In order to speedup packet filtering, here is an implementation of a JIT
>compiler for x86_64

Great work! Eric, do you have some numbers? For a trivial "ret" filter the
performance gain should be marginal - if any. But what with complex filter
rules? And as said last time: libpcap optimizer seems to be target number one
for optimization. Again: great work!

Hagen
