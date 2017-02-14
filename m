From: Ingo Molnar <mingo@kernel.org>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 14 Feb 2017 07:35:14 +0100
Message-ID: <20170214063514.GA10242@gmail.com>
References: <20170214091250.57d054b2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35846 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdBNGfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 01:35:19 -0500
Content-Disposition: inline
In-Reply-To: <20170214091250.57d054b2@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> --- a/tools/include/uapi/linux/bpf.h
> +++ b/tools/include/uapi/linux/bpf.h
> @@ -116,6 +116,12 @@ enum bpf_attach_type {
>  
>  #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
>  
> +/* If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
> + * to the given target_fd cgroup the descendent cgroup will be able to
> + * override effective bpf program that was inherited from this cgroup
> + */
> +#define BPF_F_ALLOW_OVERRIDE	(1U << 0)
> +

BTW., guys, for heaven's sake, please use the standard (multi-line) comment style:

  /*
   * Comment .....
   * ...... goes here.
   */

specified in Documentation/CodingStyle...

It's not that hard to create visually balanced patterns.

Thanks,

        Ingo
