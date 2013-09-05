From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: fix no cwnd growth after timeout
Date: Thu, 5 Sep 2013 19:56:59 -0400
Message-ID: <CADVnQynvfPtsJN-XqpTkbu4Y+=uzYcmv22GpaV=tRYL8w90TUw@mail.gmail.com>
References: <1378420569-12370-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:55429 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab3IEX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 19:57:00 -0400
Received: by mail-ea0-f182.google.com with SMTP id o10so1245614eaj.13
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 16:56:59 -0700 (PDT)
In-Reply-To: <1378420569-12370-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 6:36 PM, Yuchung Cheng <ycheng@google.com> wrote:
> In commit 0f7cc9a3 "tcp: increase throughput when reordering is high",
> it only allows cwnd to increase in Open state. This mistakenly disables
> slow start after timeout (CA_Loss). Moreover cwnd won't grow if the
> state moves from Disorder to Open later in tcp_fastretrans_alert().
>
> Therefore the correct logic should be to allow cwnd to grow as long
> as the data is received in order in Open, Loss, or even Disorder state.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
