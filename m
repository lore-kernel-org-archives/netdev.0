From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] bpf: allow programs to write to
 certain skb fields
Date: Sun, 07 Jun 2015 02:01:58 -0700 (PDT)
Message-ID: <20150607.020158.1703718660634574340.davem@davemloft.net>
References: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
	<1433437914-15808-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, jhs@mojatatu.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbbFGJB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 05:01:59 -0400
In-Reply-To: <1433437914-15808-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  4 Jun 2015 10:11:54 -0700

> allow programs read/write skb->mark, tc_index fields and
> ((struct qdisc_skb_cb *)cb)->data.
> 
> mark and tc_index are generically useful in TC.
> cb[0]-cb[4] are primarily used to pass arguments from one
> program to another called via bpf_tail_call() which can
> be seen in sockex3_kern.c example.
> 
> All fields of 'struct __sk_buff' are readable to socket and tc_cls_act progs.
> mark, tc_index are writeable from tc_cls_act only.
> cb[0]-cb[4] are writeable by both sockets and tc_cls_act.
> 
> Add verifier tests and improve sample code.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
