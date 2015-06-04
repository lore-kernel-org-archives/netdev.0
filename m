From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix build due to missing tc_verd
Date: Thu, 04 Jun 2015 11:46:16 -0700 (PDT)
Message-ID: <20150604.114616.2296101165259267787.davem@davemloft.net>
References: <1433432028-7620-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, gerlitz.or@gmail.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbFDSqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 14:46:17 -0400
In-Reply-To: <1433432028-7620-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  4 Jun 2015 08:33:48 -0700

> fix build error:
> net/core/filter.c: In function 'bpf_clone_redirect':
> net/core/filter.c:1429:18: error: 'struct sk_buff' has no member named 'tc_verd'
>   if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)
> 
> Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
> Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
