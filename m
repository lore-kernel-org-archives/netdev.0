From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Thu, 04 Oct 2012 19:17:29 +0200
Message-ID: <1349371049.16011.90.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349369406.16011.82.camel@edumazet-glaptop>
	 <1349370573.2532.25.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52510 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680Ab2JDRRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 13:17:35 -0400
In-Reply-To: <1349370573.2532.25.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 19:09 +0200, Maxime Bizon wrote:

> yes, on ipv6 forward path the default NET_SKB_PAD is too small, so each
> packet forwarded has its headroom expanded, it is then recycled and gets
> its original default headroom back, then it gets forwarded,
> expanded, ...

Hmm, this sounds bad (especially without recycle)

Might I assume NET_SKB_PAD is 32 on this arch ?

We might adjust NET_SKB_PAD to avoid all these memory copies...
