From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] net: ipv6: Use ip6_datagram_send_common
 in L2TP IPv6.
Date: Tue, 22 Apr 2014 07:23:42 -0700
Message-ID: <1398176622.29946.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
	 <1398159499-32413-1-git-send-email-lorenzo@google.com>
	 <1398159499-32413-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	hannes@stressinduktion.org, davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:60298 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaDVOXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 10:23:48 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so5015409pad.31
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 07:23:47 -0700 (PDT)
In-Reply-To: <1398159499-32413-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 18:38 +0900, Lorenzo Colitti wrote:
> This code was also virtually identical with the UDP and raw
> socket sendmsg code.
> 
> Tested: compiles with CONFIG_IPV6=Y and CONFIG_L2TP_IP=Y.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/l2tp/l2tp_ip6.c | 114 +++++-----------------------------------------------
>  1 file changed, 9 insertions(+), 105 deletions(-)

Please try CONFIG_IPV6=m and/or CONFIG_L2TP_IP=m then ;)

You forgot to EXPORT_SYMBOL(ip6_datagram_send_common)
