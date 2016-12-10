From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 net-next 2/8] bpf: export bpf_prog_load
Date: Sat, 10 Dec 2016 22:24:53 +0100
Message-ID: <584C72A5.9020801@iogearbox.net>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com> <1481401934-4026-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34896 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbcLJVYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 16:24:55 -0500
In-Reply-To: <1481401934-4026-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2016 09:32 PM, David Ahern wrote:
> Code move only; no functional change intended.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   include/bpf_util.h |  3 +++
>   lib/bpf.c          | 40 ++++++++++++++++++++--------------------
>   2 files changed, 23 insertions(+), 20 deletions(-)
>
> diff --git a/include/bpf_util.h b/include/bpf_util.h
> index 49b96bbc208f..dcbdca6978d6 100644
> --- a/include/bpf_util.h
> +++ b/include/bpf_util.h
> @@ -75,6 +75,9 @@ int bpf_trace_pipe(void);
>
>   void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
>
> +int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
> +		  size_t size_insns, const char *license, char *log,
> +		  size_t size_log);

Just a really minor nit: please add a newline here.

>   int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type);
>   int bpf_prog_detach(int target_fd, enum bpf_attach_type type);
>
