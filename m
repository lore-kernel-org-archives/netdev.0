From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 06/15] bpf: Sample bpf program to set
 initial window
Date: Tue, 13 Jun 2017 17:14:52 -0400 (EDT)
Message-ID: <20170613.171452.1515304283256474282.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-7-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdFMVOy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:14:54 -0400
In-Reply-To: <20170613180004.3008403-7-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:55 -0700

> +SEC("sockops")
> +int bpf_rwnd(struct __sk_buff *skb)
> +{
> +	struct bpf_socket_ops *skops = (struct bpf_socket_ops *) skb;
> +	char fmt1[] = "BPF command: %d\n";
> +	char fmt2[] = "  Returning %d\n";
> +	int op;
> +	int rv = -1;

Longest to shortest line for local variable declarations please.

> +
> +	// For testing purposes, only execute rest of BPF program
> +	// if neither port numberis 55601

Again, please use non-C++ comments.

Thank you.
