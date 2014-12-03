From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tcp: Add TCP tracer
Date: Tue, 2 Dec 2014 17:51:15 -0800
Message-ID: <20141202175115.53f1f56b@urahara>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
	<1417552662-16398-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46969 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaLCBv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 20:51:26 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so14698153pab.20
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 17:51:26 -0800 (PST)
In-Reply-To: <1417552662-16398-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Dec 2014 12:37:42 -0800
Martin KaFai Lau <kafai@fb.com> wrote:

> diff --git a/include/uapi/linux/tcp_trace.h b/include/uapi/linux/tcp_trace.h
> index 2644f7f..d913a3c 100644
> --- a/include/uapi/linux/tcp_trace.h
> +++ b/include/uapi/linux/tcp_trace.h
> @@ -22,11 +22,11 @@ struct tcp_stats {
>  	__u32	other_segs_retrans;
>  	__u32	other_octets_retrans;
>  	__u32	loss_segs_retrans;
> -	__u32	loss_octects_retrans;
> +	__u32	loss_octets_retrans;
>  	__u32	segs_in;
>  	__u32	data_segs_in;
> -	__u64	rtt_sample_us;
>  	__u64	data_octets_in;
> +	__u64	rtt_sample_us;
>  	__u64	max_rtt_us;
>  	__u64	min_rtt_us;
>  	__u64   sum_rtt_us;
> @@ -64,9 +64,4 @@ struct tcp_trace_stats {
>          struct tcp_stats stats;
>  } __packed;

You can't change exposed kernel API like that.
