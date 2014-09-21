From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] tcp: move logic out of
 tcp_v[64]_gso_send_check
Date: Sat, 20 Sep 2014 18:04:21 -0700
Message-ID: <1411261461.26859.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
	 <1411249950-6795-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59888 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUBEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:04:23 -0400
Received: by mail-pd0-f170.google.com with SMTP id y13so2204707pdi.29
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:04:23 -0700 (PDT)
In-Reply-To: <1411249950-6795-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 14:52 -0700, Tom Herbert wrote:
> In tcp_v[46]_gso_send_check the TCP checksum is initialized to the
> pseudo header checksum using __tcp_v[46]_send_check. We can move this
> logic into new tcp[46]_gso_segment functions to be done when
> ip_summed != CHECKSUM_PARTIAL (ip_summed == CHECKSUM_PARTIAL should be
> the common case, possibly always true when taking GSO path). After this
> change tcp_v[46]_gso_send_check is no-op.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/tcp_offload.c   | 39 +++++++++++++++++++++++----------------
>  net/ipv6/tcpv6_offload.c | 37 ++++++++++++++++++++++++-------------
>  2 files changed, 47 insertions(+), 29 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
