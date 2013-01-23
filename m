From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Tue, 22 Jan 2013 21:06:43 -0800
Message-ID: <1358917603.12374.713.camel@edumazet-glaptop>
References: <1358916229-19004-1-git-send-email-amwang@redhat.com>
	 <1358916659.12374.684.camel@edumazet-glaptop>
	 <1358917086.4235.12.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:49231 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3AWFGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:06:47 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so4424046pbc.14
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 21:06:47 -0800 (PST)
In-Reply-To: <1358917086.4235.12.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 12:58 +0800, Cong Wang wrote:

> It does fix this warning:
> 
> net/core/flow_dissector.c:280:37: sparse: incompatible types in
> comparison expression (different address spaces)

Thats not a good enough reason.

It adds 10 new warnings.
