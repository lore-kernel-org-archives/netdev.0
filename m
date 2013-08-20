From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not
 reordering
Date: Tue, 20 Aug 2013 13:33:20 -0700
Message-ID: <1377030800.4226.89.camel@edumazet-glaptop>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>
	 <1377011469-26151-2-git-send-email-mailings@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferry Huberts <mailings@hupie.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40561 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3HTUdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:33:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1151945pab.20
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 13:33:21 -0700 (PDT)
In-Reply-To: <1377011469-26151-2-git-send-email-mailings@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 17:11 +0200, Ferry Huberts wrote:
> From: Ferry Huberts <ferry.huberts@pelagic.nl>
> 
> Not doing this (current behaviour) introduces reordering.
> 
> The packet_len_2_sched_time call is the only thing that logically
> depends on q->rate, so move the now/delay adjustment out of the if.
> 
> Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
> ---
>  net/sched/sch_netem.c | 34 +++++++++++++++++-----------------
>  1 file changed, 17 insertions(+), 17 deletions(-)

I would like you to show how this was tested, for example if we have a
rate + delay + reorders.

Thanks
