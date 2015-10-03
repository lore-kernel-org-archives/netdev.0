From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/17] tcp/dccp: lockless listener
Date: Sat, 03 Oct 2015 06:03:46 -0700
Message-ID: <1443877426.32531.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
	 <20151003.044835.592539615085639060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ycai@google.com,
	willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36479 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbbJCNDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 09:03:48 -0400
Received: by pablk4 with SMTP id lk4so130869788pab.3
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 06:03:48 -0700 (PDT)
In-Reply-To: <20151003.044835.592539615085639060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-10-03 at 04:48 -0700, David Miller wrote:

> This looks amazing, series applied, thanks Eric!

Thanks David.

While splitting my patches, it seems I somehow missed one change, adding
SLAB_DESTROY_BY_RCU flag for request kmem_cache.

I will send the patch in few minutes.
