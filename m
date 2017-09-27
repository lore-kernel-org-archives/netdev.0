From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 3/6] bpf: update bpf.h uapi header for tools
Date: Wed, 27 Sep 2017 09:03:34 +0200
Message-ID: <20170927090315.22070171@brouer.com>
References: <cover.1506297988.git.daniel@iogearbox.net>
        <4bdb49b4387d698443e32b8a6a85414e57ef4de0.1506297988.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbdI0HDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 03:03:41 -0400
In-Reply-To: <4bdb49b4387d698443e32b8a6a85414e57ef4de0.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 02:25:52 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Looks like a couple of updates missed to get carried into tools/include/uapi/,
> so copy the bpf.h header as usual to pull in latest updates.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: John Fastabend <john.fastabend@gmail.com>
> ---
>  tools/include/uapi/linux/bpf.h | 45 ++++++++++++++++++++++++++++++------------
>  1 file changed, 32 insertions(+), 13 deletions(-)
> 
> diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
> index 461811e..e43491a 100644
> --- a/tools/include/uapi/linux/bpf.h
> +++ b/tools/include/uapi/linux/bpf.h
> @@ -143,12 +143,6 @@ enum bpf_attach_type {
>  
>  #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
>  
> -enum bpf_sockmap_flags {
> -	BPF_SOCKMAP_UNSPEC,
> -	BPF_SOCKMAP_STRPARSER,
> -	__MAX_BPF_SOCKMAP_FLAG
> -};
> -

Why does "bpf_sockmap_flags" gets removed?

It got added in: commit 69e8cc134bcb ("bpf: sockmap sample program").
But I cannot find any users of these flags, so I guess it is okay.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
