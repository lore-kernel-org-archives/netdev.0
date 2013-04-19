From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove one indentation level in
 tcp_rcv_state_process()
Date: Fri, 19 Apr 2013 10:04:48 -0700
Message-ID: <1366391088.16391.27.camel@edumazet-glaptop>
References: <1366341367.3205.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:59518 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab3DSREu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:04:50 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2325211pdi.7
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 10:04:50 -0700 (PDT)
In-Reply-To: <1366341367.3205.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 20:16 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Remove one level of indentation 'introduced' in commit
> c3ae62af8e75 (tcp: should drop incoming frames without ACK flag set)
> 
> @acceptable variable is a boolean.
> 
> This patch is a pure cleanup.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---

Please drop this patch, I'll respin it later, when the "call
tcp_replace_ts_recent() from tcp_ack()" issues are sorted out.

Thanks
