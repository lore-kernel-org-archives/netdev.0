From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] VSOCK: add sock_diag interface
Date: Tue, 03 Oct 2017 21:46:52 -0700 (PDT)
Message-ID: <20171003.214652.1920235341803755309.davem@davemloft.net>
References: <20171003153943.23159-1-stefanha@redhat.com>
        <20171003153943.23159-5-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJDEqw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:46:52 -0400
In-Reply-To: <20171003153943.23159-5-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Tue,  3 Oct 2017 11:39:42 -0400

> +static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
> +			u32 portid, u32 seq, u32 flags)
> +{
> +	struct nlmsghdr *nlh;
> +	struct vsock_diag_msg *rep;
> +	struct vsock_sock *vsk = vsock_sk(sk);

Please order local variables from longest to shortest line.

> +static int vsock_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	struct vsock_diag_req *req;
> +	unsigned int table;
> +	unsigned int bucket;
> +	unsigned int last_i;
> +	unsigned int i;
> +	struct vsock_sock *vsk;
> +	struct net *net;

Likewise.
