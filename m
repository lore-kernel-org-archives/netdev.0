From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v2 06/11] tbf: improved accuracy at high rates
Date: Fri, 08 Feb 2013 11:09:48 -0800
Message-ID: <1360350588.28557.107.camel@edumazet-glaptop>
References: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
	 <1360349981-27801-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:61940 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760295Ab3BHTJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:09:51 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so4601156iaz.2
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 11:09:50 -0800 (PST)
In-Reply-To: <1360349981-27801-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 19:59 +0100, Jiri Pirko wrote:
> Current TBF uses rate table computed by the "tc" userspace program,
> which has the following issue:
> 
> The rate table has 256 entries to map packet lengths to
> token (time units).  With TSO sized packets, the 256 entry granularity
> leads to loss/gain of rate, making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch explicitly computes
> the time and accounts for packet transmission times with nanosecond
> granularity.
> 
> This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
