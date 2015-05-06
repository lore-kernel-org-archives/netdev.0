From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add TCPWinProbe and TCPKeepAlive
 SNMP counters
Date: Wed, 6 May 2015 18:12:48 -0400
Message-ID: <CADVnQym=zqae9J5wWbwFT_1hRR9BL_65NjrT_L+ArA=0K9BfUQ@mail.gmail.com>
References: <1430947585-2375-1-git-send-email-edumazet@google.com>
	<1430947585-2375-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:33974 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbEFWMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:12:48 -0400
Received: by obfe9 with SMTP id e9so18147274obf.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 15:12:48 -0700 (PDT)
In-Reply-To: <1430947585-2375-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 5:26 PM, Eric Dumazet <edumazet@google.com> wrote:
> Diagnosing problems related to Window Probes has been hard because
> we lack a counter.
>
> TCPWinProbe counts the number of ACK packets a sender has to send
> at regular intervals to make sure a reverse ACK packet opening back
> a window had not been lost.
>
> TCPKeepAlive counts the number of ACK packets sent to keep TCP
> flows alive (SO_KEEPALIVE)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
