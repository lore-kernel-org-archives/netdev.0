From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 10/15] bpf: Add support for changing
 congestion control
Date: Tue, 13 Jun 2017 17:17:53 -0400 (EDT)
Message-ID: <20170613.171753.599206923549927704.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-11-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51326 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752452AbdFMVRz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:17:55 -0400
In-Reply-To: <20170613180004.3008403-11-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:59 -0700

> @@ -2698,8 +2698,15 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
>  		}
>  	} else if (level == SOL_TCP &&
>  		   bpf_socket->sk->sk_prot->setsockopt == tcp_setsockopt) {
> -		// Place holder
> -		ret = -EINVAL;

I missed these C++ comments in an earlier patch, definitely don't use
them in kernel code.

Thanks.
