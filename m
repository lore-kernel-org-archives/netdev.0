From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 11:48:14 -0700
Message-ID: <20160920114814.04f0f394@xeon-e3>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
        <1474342763-16715-17-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33309 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752731AbcITSsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 14:48:03 -0400
Received: by mail-pa0-f46.google.com with SMTP id hm5so9688311pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 11:48:03 -0700 (PDT)
In-Reply-To: <1474342763-16715-17-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 23:39:23 -0400
Neal Cardwell <ncardwell@google.com> wrote:

> +/* INET_DIAG_BBRINFO */
> +
> +struct tcp_bbr_info {
> +	/* u64 bw: max-filtered BW (app throughput) estimate in Byte per sec: */
> +	__u32	bbr_bw_lo;		/* lower 32 bits of bw */
> +	__u32	bbr_bw_hi;		/* upper 32 bits of bw */
> +	__u32	bbr_min_rtt;		/* min-filtered RTT in uSec */
> +	__u32	bbr_pacing_gain;	/* pacing gain shifted left 8 bits */
> +	__u32	bbr_cwnd_gain;		/* cwnd gain shifted left 8 bits */
> +};
> +

I assume there is a change to iproute (ss) to dump this info?
