From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp-tso: do not split TSO packets at
 retransmit time
Date: Mon, 25 Apr 2016 10:43:47 -0700
Message-ID: <1461606227.5535.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
	 <1461605974-4242-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33491 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbcDYRnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:43:49 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so20132057pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 10:43:48 -0700 (PDT)
In-Reply-To: <1461605974-4242-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-25 at 10:39 -0700, Eric Dumazet wrote:
> Linux TCP stack painfully segments all TSO/GSO packets before retransmits.
> 

humpf.


> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/net/tcp.h     |  4 ++--
>  net/ipv4/tcp_input.c  |  2 +-
>  net/ipv4/tcp_output.c | 64 +++++++++++++++++++++++----------------------------
>  net/ipv4/tcp_timer.c  |  4 ++--
>  4 files changed, 34 insertions(+), 40 deletions(-)

Please ignore, I forgot to clean this one, it was already merged.

Sorry for the noise.
