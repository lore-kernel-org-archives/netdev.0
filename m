From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 03/21] iplink: bridge: export read-only timers
Date: Mon, 8 Feb 2016 14:23:40 -0800
Message-ID: <20160208142340.74ec14da@xeon-e3>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
	<1454932527-30569-4-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35987 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752820AbcBHWYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 17:24:07 -0500
Received: by mail-pf0-f176.google.com with SMTP id e127so20955649pfe.3
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 14:24:07 -0800 (PST)
In-Reply-To: <1454932527-30569-4-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Feb 2016 12:55:09 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> +
> +	if (tb[IFLA_BR_HELLO_TIMER])
> +		fprintf(f, "hello_timer %llu ",
> +			rta_getattr_u64(tb[IFLA_BR_HELLO_TIMER]));
> +
> +	if (tb[IFLA_BR_TCN_TIMER])
> +		fprintf(f, "tcn_timer %llu ",
> +			rta_getattr_u64(tb[IFLA_BR_TCN_TIMER]));
> +
> +	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER])
> +		fprintf(f, "topology_change_timer %llu ",
> +			rta_getattr_u64(tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]));
> +
> +	if (tb[IFLA_BR_GC_TIMER])
> +		fprintf(f, "gc_timer %llu ",
> +

These should be rescaled as seconds.
