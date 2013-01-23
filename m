From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Wed, 23 Jan 2013 13:30:57 +0800
Message-ID: <1358919057.4235.17.camel@cr0>
References: <1358916229-19004-1-git-send-email-amwang@redhat.com>
	 <1358916659.12374.684.camel@edumazet-glaptop>
	 <1358917086.4235.12.camel@cr0>
	 <1358917603.12374.713.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab3AWFbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 00:31:09 -0500
In-Reply-To: <1358917603.12374.713.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 21:06 -0800, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 12:58 +0800, Cong Wang wrote:
> 
> > It does fix this warning:
> > 
> > net/core/flow_dissector.c:280:37: sparse: incompatible types in
> > comparison expression (different address spaces)
> 
> Thats not a good enough reason.
> 
> It adds 10 new warnings.
> 
> 

I expect most of them are from decnet, which is (partially) deprecated?
