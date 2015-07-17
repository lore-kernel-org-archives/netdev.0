From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] rhashtable: Allow other tasks to be
 scheduled in large lookup loops
Date: Fri, 17 Jul 2015 11:49:34 +0200
Message-ID: <1437126574.1026.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, mroos@linux.ee,
	herbert@gondor.apana.org.au
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34506 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787AbbGQJti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 05:49:38 -0400
Received: by wibud3 with SMTP id ud3so35066742wib.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 02:49:37 -0700 (PDT)
In-Reply-To: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 10:52 +0200, Thomas Graf wrote:
> Depending on system speed, the large lookup/insert/delete loops of the testsuite can
> take a considerable amount of time to complete causing watchdog warnings to appear.
> Allow other tasks to be scheduled throughout the loops.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: Use cond_resched() instead schedule()

Acked-by: Eric Dumazet <edumazet@google.com>
