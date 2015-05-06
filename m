From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp: add TCPWinProbe SNMP counter
Date: Wed, 06 May 2015 13:00:10 -0700
Message-ID: <1430942410.14545.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430916734-5051-1-git-send-email-edumazet@google.com>
	 <1430916734-5051-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34103 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbbEFUAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:00:12 -0400
Received: by iget9 with SMTP id t9so105411475ige.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 13:00:11 -0700 (PDT)
In-Reply-To: <1430916734-5051-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-06 at 05:52 -0700, Eric Dumazet wrote:
> Diagnosing problems related to Window Probes has been hard because
> we lacked a counter.
> 
> TCPWinProbe counts the number of ACK packets a sender has to transmit
> at regular intervals to make sure a reverse ACK packet opening back
> a zero window had not been lost.

As Yuchung & Neal suggested, we'll introduce a separate TCPKeepAlive
SNMP counter in V2

Please do not apply this patch, thanks !
