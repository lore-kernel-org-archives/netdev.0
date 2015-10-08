From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: clear sender_cpu before xmit
Date: Thu, 08 Oct 2015 05:06:56 -0700 (PDT)
Message-ID: <20151008.050656.1281225463647986015.davem@davemloft.net>
References: <1444189567-3031-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbJHLvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:51:08 -0400
In-Reply-To: <1444189567-3031-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  6 Oct 2015 20:46:07 -0700

> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
> the skb->sender_cpu needs to be cleared before xmit.
> 
> Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable.
