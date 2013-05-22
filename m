From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 13:48:56 -0700
Message-ID: <1369255736.3301.358.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <1369246816.2143.84.camel@joe-AO722>
	 <1369250772.3301.349.camel@edumazet-glaptop>
	 <1369252624.2143.103.camel@joe-AO722>
	 <1369253761.3301.355.camel@edumazet-glaptop>
	 <1369255104.2143.108.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:57485 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757319Ab3EVUs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 16:48:58 -0400
In-Reply-To: <1369255104.2143.108.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 13:38 -0700, Joe Perches wrote:

> u16 for cpu is hardly used at all.

Its used in network tree.

The day it has to change, don't worry, I think we'll be able to handle
it.

For the meantime, I do not want to add 4 more bytes to conntrack
structure, its already bloated enough.
