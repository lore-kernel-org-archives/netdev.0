From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 31 Oct 2016 12:58:01 -0400 (EDT)
Message-ID: <20161031.125801.874510216543796824.davem@davemloft.net>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
        <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51310 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944588AbcJaQ6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 12:58:07 -0400
In-Reply-To: <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 26 Oct 2016 17:58:38 -0700

> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 6b62ee9a2f78..73da296c2125 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -98,7 +98,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_TRACEPOINT,
>  	BPF_PROG_TYPE_XDP,
>  	BPF_PROG_TYPE_PERF_EVENT,
> -	BPF_PROG_TYPE_CGROUP_SKB,
> +	BPF_PROG_TYPE_CGROUP,
>  };
>  
>  enum bpf_attach_type {

If we do this then the cgroup-bpf series should use this value rather than
changing it after-the-fact in your series here.
