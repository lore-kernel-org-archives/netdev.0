From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bpf: performance improvements
Date: Thu, 17 Sep 2015 21:10:36 -0700 (PDT)
Message-ID: <20150917.211036.1009756957325738297.davem@davemloft.net>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, jhs@mojatatu.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbIREKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:10:37 -0400
In-Reply-To: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 15 Sep 2015 23:05:41 -0700

> v1->v2: dropped redundant iff_up check in patch 2
> 
> At plumbers we discussed different options on how to get rid of skb_clone
> from bpf_clone_redirect(), the patch 2 implements the best option.
> Patch 1 adds 'integrated exts' to cls_bpf to improve performance by
> combining simple actions into bpf classifier.

Series applied, thanks.
