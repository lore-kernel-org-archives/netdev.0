From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Thu, 25 Apr 2013 15:48:32 -0700
Message-ID: <1366930112.8964.180.camel@edumazet-glaptop>
References: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:46623 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758173Ab3DYWsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 18:48:35 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so2073510pdj.12
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 15:48:34 -0700 (PDT)
In-Reply-To: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 14:08 -0700, Pravin B Shelar wrote:
> Following patch adds icmp-registration module for ipv6.  It allows
> ipv6 protocol to register icmp_sender which is used for sending
> ipv6 icmp msgs.  This extra layer allows us to kill ipv6 dependency
> for sending icmp packets.
> 
> This patch also fixes ip_tunnel compilation problem when ip_tunnel
> is statically compiled in kernel but ipv6 is module
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
