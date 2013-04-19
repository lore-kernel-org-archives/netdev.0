From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: call tcp_replace_ts_recent() from tcp_ack()
Date: Fri, 19 Apr 2013 10:18:36 -0700
Message-ID: <1366391916.16391.31.camel@edumazet-glaptop>
References: <1366384390.16391.17.camel@edumazet-glaptop>
	 <CADVnQymOBoJ9687qn9-fQCXdMcuaP23-bP-Y1ZS0aoYqCdaFVg@mail.gmail.com>
	 <1366390793.16391.24.camel@edumazet-glaptop>
	 <1366390919.16391.25.camel@edumazet-glaptop>
	 <CADVnQy=MSA+ZApkyLHK=Bm25wsyma7PDnZuOVZmcTmqsgyZ_ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:57422 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab3DSRSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:18:39 -0400
Received: by mail-pb0-f47.google.com with SMTP id rq13so83423pbb.34
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 10:18:38 -0700 (PDT)
In-Reply-To: <CADVnQy=MSA+ZApkyLHK=Bm25wsyma7PDnZuOVZmcTmqsgyZ_ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 13:14 -0400, Neal Cardwell wrote:

> Good point. How about fixing both tcp_replace_ts_recent() call sites
> in net-next, as a single patch after your  "tcp: remove one
> indentation level in tcp_rcv_state_process()" net-next patch?

I think the cleanup can be delayed, I'll resend a v2 of the fix.

Thanks
