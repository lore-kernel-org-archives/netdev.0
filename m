From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 07/15] bpf: Add setsockopt helper function
 to bpf
Date: Tue, 13 Jun 2017 17:16:41 -0400 (EDT)
Message-ID: <20170613.171641.971171683474923625.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-8-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51304 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753436AbdFMVQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:16:43 -0400
In-Reply-To: <20170613180004.3008403-8-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:56 -0700

> +BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
> +	   int, level, int, optname, char *, optval, int, optlen)
> +{
> +	int val;
> +	int ret = 0;
> +	struct sock *sk = bpf_socket->sk;

Longest to shortest line for variable declarations please.

Also, throughout your submission make sure you indent multi-line
function declarations and definitions properly.  It needs to be:

return_type function_name(type1 arg1, type2 arg2, type3 arg3,
			  type4 arg4, type5 arg5)

such that "type4 arg4" starts precisely at the first column after
the openning parenthesis of the first line.  You must use the
appropriate number of TAB then SPACE characters necessary to
achieve this.

Thank you.
