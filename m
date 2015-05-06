From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add TCPWinProbe and TCPKeepAlive
 SNMP counters
Date: Wed, 6 May 2015 18:13:15 -0400
Message-ID: <CADVnQy=hcpRAOueTS=-eP3=b_6GSOdus0fWycAJj--aH35wyOg@mail.gmail.com>
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
Received: from mail-ob0-f177.google.com ([209.85.214.177]:36811 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbbEFWNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:13:16 -0400
Received: by obbkp3 with SMTP id kp3so18120230obb.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 15:13:16 -0700 (PDT)
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

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
