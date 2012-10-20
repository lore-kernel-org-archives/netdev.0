From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: add SYN/data info to TCP_INFO
Date: Sat, 20 Oct 2012 09:50:20 +0200
Message-ID: <1350719420.13333.344.camel@edumazet-glaptop>
References: <1350695684-26962-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	hkchu@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39848 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2JTHuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 03:50:24 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so607904wey.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 00:50:23 -0700 (PDT)
In-Reply-To: <1350695684-26962-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 18:14 -0700, Yuchung Cheng wrote:
> Add a bit TCPI_OPT_SYN_DATA (32) to the socket option TCP_INFO:tcpi_options.
> It's set if the data in SYN (sent or received) is acked by SYN-ACK. Server or
> client application can use this information to check Fast Open success rate.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
