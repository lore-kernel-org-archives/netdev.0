From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 20:41:33 +0200
Message-ID: <1340217693.4604.1576.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop> <4FE1FABF.6040309@intel.com>
	 <4FE20511.4000206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51842 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423Ab2FTSli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 14:41:38 -0400
Received: by bkcji2 with SMTP id ji2so6524962bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 11:41:37 -0700 (PDT)
In-Reply-To: <4FE20511.4000206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 10:14 -0700, Alexander Duyck wrote:

> Actually I think I just realized what the difference is.  I was looking
> at things with LRO disabled.  With LRO enabled our hardware RSC feature
> kind of defeats the whole point of the GRO or TCP coalescing anyway
> since it will stuff 16 fragments into a single packet before we even
> hand the packet off to the stack.

I noticed LRO was now 'off' by default on ixgbe (net-next tree), I am
pretty sure it was 'on' some months ago ?
