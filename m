From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 2/2] ipv4: add a sock pointer to dst->output() path.
Date: Thu, 14 Aug 2014 15:16:44 -0700 (PDT)
Message-ID: <20140814.151644.1076362729497460962.davem@redhat.com>
References: <20140415.134916.1941040568700162970.davem@davemloft.net>
	<20140813170243.GA1869@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nasa4836@gmail.com, jchapman@katalix.com,
	lucien.xin@gmail.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754834AbaHNWQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 18:16:54 -0400
In-Reply-To: <20140813170243.GA1869@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 13 Aug 2014 19:02:43 +0200

> The question is, is it the correct way? Or perhaps something like
> skb->output_sk would serve this better?

Adding members to sk_buff is strongly discouraged, especially when the
issue here is simply rearranging things, as needed, so that it's easy
to pass the 'sk' through the call chain.
