From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 07/11] tbf: improved accuracy at high rates
Date: Tue, 12 Feb 2013 08:34:01 -0800
Message-ID: <1360686841.6884.1.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:58278 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933406Ab3BLQeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:34:05 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so99111dam.32
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:34:05 -0800 (PST)
In-Reply-To: <1360663929-1023-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>
