From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] samples/bpf: add samples for HW_CACHE /
 RAW events
Date: Mon, 22 May 2017 19:26:51 -0400 (EDT)
Message-ID: <20170522.192651.252662920166760334.davem@davemloft.net>
References: <20170522224840.810121-1-ast@fb.com>
        <20170522224840.810121-3-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        qinteng@fb.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759952AbdEVX04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 19:26:56 -0400
In-Reply-To: <20170522224840.810121-3-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 22 May 2017 15:48:40 -0700

> @@ -31,7 +31,7 @@ static unsigned long long (*bpf_get_current_uid_gid)(void) =
>  	(void *) BPF_FUNC_get_current_uid_gid;
>  static int (*bpf_get_current_comm)(void *buf, int buf_size) =
>  	(void *) BPF_FUNC_get_current_comm;
> -static int (*bpf_perf_event_read)(void *map, int index) =
> +static u64 (*bpf_perf_event_read)(void *map, u64 flags) =
>  	(void *) BPF_FUNC_perf_event_read;

If the second argument really is "u64 flags", then please update
the comments in tools/include/uapi/linux/bpf.h as well.

Thank you.
