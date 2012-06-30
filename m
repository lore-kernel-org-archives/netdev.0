From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Sat, 30 Jun 2012 10:39:40 +0200
Message-ID: <1341045580.21162.38.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
	 <1340198514.4604.970.camel@edumazet-glaptop>  <4FE29DE4.1010705@gmail.com>
	 <1340255226.4604.3774.camel@edumazet-glaptop>
	 <1340368430.4604.10280.camel@edumazet-glaptop> <4FEE3487.9080408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:64278 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab2F3Ijp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 04:39:45 -0400
Received: by wgbds11 with SMTP id ds11so1465586wgb.1
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 01:39:43 -0700 (PDT)
In-Reply-To: <4FEE3487.9080408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 16:04 -0700, Alexander Duyck wrote:

> I was wondering if there were any plans to clean this patch up and
> submit it to net-next?  If not, I can probably work on that since this
> addressed the concerns I had in my original patch.
> 

I used this patch for a while on my machines, but I am working on
something allowing fallback to order-0 allocations if memory gets
fragmented. This fallback should almost never happen, but we should have
it just in case ?
