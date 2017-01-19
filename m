From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: initialize max window for a new fastopen socket
Date: Thu, 19 Jan 2017 05:41:09 -0800
Message-ID: <1484833269.16328.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484832999-1849-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36649 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752747AbdASNto (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 08:49:44 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so4241435pgf.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 05:49:19 -0800 (PST)
In-Reply-To: <1484832999-1849-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 16:36 +0300, Alexey Kodanev wrote:
> Found that if we run LTP netstress test with large MSS (65K),
> the first attempt from server to send data comparable to this
> MSS on fastopen connection will be delayed by the probe timer.

> 
> This also contradicts with the fact that we should bound to the half
> of the window if it is large.
> 
> Fix this flaw by correctly initializing max_window. Before that, it
> could have large values that affect further calculations of 'size_goal'.
> 
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Alexey !
