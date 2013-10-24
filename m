From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix SYNACK RTT estimation in Fast Open
Date: Thu, 24 Oct 2013 13:02:13 -0400
Message-ID: <CADVnQymY0C=awBucRiePAy04ZYK5SW68aNjEYrpF87BAhN79+w@mail.gmail.com>
References: <1382629465-20310-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, panweiping3@gmail.com,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:41670 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab3JXRCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 13:02:15 -0400
Received: by mail-ea0-f179.google.com with SMTP id b10so1373864eae.38
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 10:02:14 -0700 (PDT)
In-Reply-To: <1382629465-20310-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 11:44 AM, Yuchung Cheng <ycheng@google.com> wrote:
> tp->lsndtime may not always be the SYNACK timestamp if a passive
> Fast Open socket sends data before handshake completes. And if the
> remote acknowledges both the data and the SYNACK, the RTT sample
> is already taken in tcp_ack(), so no need to call
> tcp_update_ack_rtt() in tcp_synack_rtt_meas() aagain.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
