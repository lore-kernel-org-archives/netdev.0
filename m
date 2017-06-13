From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 09/15] bpf: Sample BPF program to set
 buffer sizes
Date: Tue, 13 Jun 2017 17:17:07 -0400 (EDT)
Message-ID: <20170613.171707.2024415777832835116.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-10-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbdFMVRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:17:09 -0400
In-Reply-To: <20170613180004.3008403-10-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:58 -0700

> diff --git a/samples/bpf/tcp_bufs_kern.c b/samples/bpf/tcp_bufs_kern.c
> new file mode 100644
> index 0000000..a407b73
> --- /dev/null
> +++ b/samples/bpf/tcp_bufs_kern.c
...
> +SEC("sockops")
> +int bpf_bufs(struct __sk_buff *skb)
> +{
> +	struct bpf_socket_ops *skops = (struct bpf_socket_ops *) skb;
> +	char fmt1[] = "BPF command: %d\n";
> +	char fmt2[] = "  Returning %d\n";
> +	int op;
> +	int rv = 0;
> +	int rwnd_init = 40;
> +	int bufsize = 1500000;
> +
> +	// For testing purposes, only execute rest of BPF program
> +	// if neither port numberis 55601

Local variable ordering and C++ comments.

Thanks.
