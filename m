From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/3] ss: output TCP BBR diag information
Date: Wed, 21 Sep 2016 16:31:20 -0700
Message-ID: <20160921163120.03c126d3@xeon-e3>
References: <1474425824-22646-1-git-send-email-ncardwell@google.com>
        <1474425824-22646-3-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34382 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753878AbcIUXbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:31:10 -0400
Received: by mail-pa0-f51.google.com with SMTP id wk8so22820320pab.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 16:31:10 -0700 (PDT)
In-Reply-To: <1474425824-22646-3-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 22:43:44 -0400
Neal Cardwell <ncardwell@google.com> wrote:

> Dump useful TCP BBR state information from a struct tcp_bbr_info that
> was grabbed using the inet_diag API.
> 
> We tolerate info that is shorter or longer than expected, in case the
> kernel is older or newer than the ss binary. We simply print the
> minimum of what is expected from the kernel and what is provided from
> the kernel. We use the same trick as that used for struct tcp_info:
> when the info from the kernel is shorter than we hoped, we pad the end
> with zeroes, and don't print fields if they are zero.
> 
> The BBR output looks like:
>   bbr:(bw:1.2Mbps,mrtt:18.965,pacing_gain:2.88672,cwnd_gain:2.88672)
> 
> The motivation here is to be consistent with DCTCP, which looks like:
>   dctcp(ce_state:23,alpha:23,ab_ecn:23,ab_tot:23)
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied, to net-next.
The first two patches were unnecessary. Already picked up current net-next headers.
