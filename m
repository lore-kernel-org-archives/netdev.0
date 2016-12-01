From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] ss: print new tcp_info fields:
 delivery_rate and app_limited
Date: Thu, 1 Dec 2016 11:01:41 -0800
Message-ID: <20161201110141.75c5af29@xeon-e3>
References: <1480616500-16919-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33397 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcLATBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:01:44 -0500
Received: by mail-pf0-f173.google.com with SMTP id d2so47550641pfd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:01:44 -0800 (PST)
In-Reply-To: <1480616500-16919-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Dec 2016 13:21:39 -0500
Neal Cardwell <ncardwell@google.com> wrote:

> Dump the new delivery_rate and delivery_rate_app_limited fields that
> were added to tcp_info in Linux v4.9.
> 
> Example output:
>   pacing_rate 65.7Mbps delivery_rate 62.9Mbps
> 
> And for the application-limited case this looks like:
>   pacing_rate 1031.1Mbps delivery_rate 87.4Mbps app_limited
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Looks good, applied to net-next branch
