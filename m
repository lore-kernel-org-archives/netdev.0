From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO not 10G friendly if peer is close enough
Date: Wed, 18 Apr 2012 05:00:38 +0200
Message-ID: <1334718038.2472.76.camel@edumazet-glaptop>
References: <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <20120417.174759.327568768780440362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	john.r.fastabend@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59324 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab2DRDAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 23:00:43 -0400
Received: by wejx9 with SMTP id x9so4429738wej.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 20:00:42 -0700 (PDT)
In-Reply-To: <20120417.174759.327568768780440362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 17:47 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 17 Apr 2012 23:38:42 +0200
> 
> > Hmm... maybe tcp_trim_head should not trim but only update an offset in
> > skb... With some luck, offset can reach skb->len when all data is
> > ACKnowledged...
> 
> This is definitely the way to fix this.  Just essentially defer all
> the page operations until later when the entire SKB is consumed.

Yes, I'll implement this today.

Thanks 
