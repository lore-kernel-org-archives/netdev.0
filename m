From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 20:18:07 -0700
Message-ID: <CA+mtBx98WhZuY=9Wg7FTpXobT_MmsYgEtcBfXptMqfy7+VwxqA@mail.gmail.com>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
	<1331521833.2449.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48480 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab2CLDSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 23:18:08 -0400
Received: by yhmm54 with SMTP id m54so2118698yhm.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 20:18:08 -0700 (PDT)
In-Reply-To: <1331521833.2449.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am concerned by the fact that socket might be not locked here, so this
> code is racy if two threads happen to call this at the same time.
>
> Or maybe its locked and I am too lazy ? :)
>
It's much more likely I'm being lazy :-)  will fix.

Tom
