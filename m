From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 net-next 3/8] Add libbpf.h header with BPF_ macros
Date: Sat, 10 Dec 2016 22:27:00 +0100
Message-ID: <584C7324.8070709@iogearbox.net>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com> <1481401934-4026-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35064 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751360AbcLJV1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 16:27:01 -0500
In-Reply-To: <1481401934-4026-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2016 09:32 PM, David Ahern wrote:
> Based on version in kernel repo, samples/bpf/libbpf.h
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   include/libbpf.h | 184 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 184 insertions(+)
>   create mode 100644 include/libbpf.h
>
> diff --git a/include/libbpf.h b/include/libbpf.h
> new file mode 100644
> index 000000000000..37951f509a10
> --- /dev/null
> +++ b/include/libbpf.h
> @@ -0,0 +1,184 @@
> +/* eBPF mini library */
> +#ifndef __LIBBPF_H
> +#define __LIBBPF_H

Creating include/libbpf.h is a bit confusing, since all the function
declarations of the current bpf lib code are located in include/bpf_util.h.
Please add all this there as well instead of creating a new file.
