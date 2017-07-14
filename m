From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/5] tcp_bbr: cut pacing rate only if filled pipe
Date: Fri, 14 Jul 2017 15:36:46 -0700
Message-ID: <20170714153646.1cdc5f00@xeon-e3>
References: <20170714214925.30720-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34811 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751085AbdGNWgy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 18:36:54 -0400
Received: by mail-pg0-f49.google.com with SMTP id t186so51879150pgb.1
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 15:36:53 -0700 (PDT)
In-Reply-To: <20170714214925.30720-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Jul 2017 17:49:21 -0400
Neal Cardwell <ncardwell@google.com> wrote:

> In bbr_set_pacing_rate(), which decides whether to cut the pacing
> rate, there was some code that considered exiting STARTUP to be
> equivalent to the notion of filling the pipe (i.e.,
> bbr_full_bw_reached()). Specifically, as the code was structured,
> exiting STARTUP and going into PROBE_RTT could cause us to cut the
> pacing rate down to something silly and low, based on whatever
> bandwidth samples we've had so far, when it's possible that all of
> them have been small app-limited bandwidth samples that are not
> representative of the bandwidth available in the path. (The code was
> correct at the time it was written, but the state machine changed
> without this spot being adjusted correspondingly.)
> 
> Fixes: 0f8782ea1497 ("tcp_bbr: add BBR congestion control")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Looks good, but net-next is closed at this time. Please resubmit later.

http://vger.kernel.org/~davem/net-next.html
