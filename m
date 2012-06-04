From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drop_monitor: dont sleep in atomic context
Date: Mon, 04 Jun 2012 12:05:41 +0200
Message-ID: <1338804341.2760.1792.camel@edumazet-glaptop>
References: <1338801163.2760.1786.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56179 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab2FDKFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 06:05:45 -0400
Received: by eaak11 with SMTP id k11so1091248eaa.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 03:05:44 -0700 (PDT)
In-Reply-To: <1338801163.2760.1786.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 11:12 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> drop_monitor calls several sleeping functions while in atomic context.
>   [<ffffffff816be6d0>] ? gs_change+0xb/0xb
> 

> Rework the logic to call the sleeping functions in right context.
> 
> Also avoid a loop if reset_per_cpu_data() cannot allocate memory :
> use mod_timer() to wait 1/10 second before next try.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> ---

I'll send a v2, please ignore this one
