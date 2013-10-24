From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: only take RTT from timestamps if new data is acked
Date: Thu, 24 Oct 2013 13:02:41 -0400
Message-ID: <CADVnQymFsQ8MYzi3NLLEXfQB25z-A-ELMyWJcD+2Qasc8mX8XA@mail.gmail.com>
References: <1382630125-21416-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:55903 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab3JXRCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 13:02:42 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so1599413eek.16
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 10:02:41 -0700 (PDT)
In-Reply-To: <1382630125-21416-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 11:55 AM, Yuchung Cheng <ycheng@google.com> wrote:
> Patch ed08495c3 "tcp: use RTT from SACK for RTO" has a bug that
> it does not check if the ACK acknowledge new data before taking
> the RTT sample from TCP timestamps. This patch adds the check
> back as required by the RFC.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
