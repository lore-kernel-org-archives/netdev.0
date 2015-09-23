From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sched, bpf: let stack handle !IFF_UP devs on
 bpf_clone_redirect
Date: Wed, 23 Sep 2015 14:26:14 -0700 (PDT)
Message-ID: <20150923.142614.1207533432015286248.davem@davemloft.net>
References: <a03c9b9daa9f779937fce9f6050a05a2dfeaaeec.1443039304.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbbIWV0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:26:15 -0400
In-Reply-To: <a03c9b9daa9f779937fce9f6050a05a2dfeaaeec.1443039304.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 23 Sep 2015 22:20:15 +0200

> Similarly as already the case in bpf_redirect()/skb_do_redirect()
> pair, let the stack deal with devs that are !IFF_UP.
> 
> dev_forward_skb() as well as dev_queue_xmit() will free the skb
> and increment drop counter internally in such cases, so we can
> spare the condition in bpf_clone_redirect().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
