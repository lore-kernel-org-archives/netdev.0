From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 10:02:25 +0200
Message-ID: <1333008145.2325.275.camel@edumazet-glaptop>
References: <20120329074443.GB2098@minipsycho>
	 <20120329.034957.655153582806618222.davem@davemloft.net>
	 <20120329075410.GC2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61920 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab2C2ICd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 04:02:33 -0400
Received: by eekc41 with SMTP id c41so748673eek.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 01:02:32 -0700 (PDT)
In-Reply-To: <20120329075410.GC2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 09:54 +0200, Jiri Pirko wrote:

> Yep, I'm aware. I must admit that the JIT code scares me a litte :(
> 

If you add a new XOR instruction in interpreter only, JIT compiler will
automatically aborts, so no risk.

Each arch maintainer will add the support for the new instructions as
separate patches.

So you can focus on net/core/filter.c file only.
