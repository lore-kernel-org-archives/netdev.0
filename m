From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: pass up EMSGSIZE msg for UDP socket in
 Ipv6
Date: Thu, 18 Feb 2016 08:58:00 +0100
Message-ID: <1455782280.648.4.camel@edumazet-ThinkPad-T530>
References: <1455746302-53543-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37332 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933511AbcBRH6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 02:58:05 -0500
Received: by mail-wm0-f45.google.com with SMTP id g62so12903126wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 23:58:05 -0800 (PST)
In-Reply-To: <1455746302-53543-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mer., 2016-02-17 at 13:58 -0800, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> In ipv4,  when  the machine receives a ICMP_FRAG_NEEDED message,  the
> connected UDP socket will get EMSGSIZE message on its next read from the
> socket.
> However, this is not the case for ipv6.
> This fix modifies the udp err handler in Ipv6 for ICMP6_PKT_TOOBIG to
> make it similar to ipv4 behavior. That is when the machine gets an
> ICMP6_PKT_TOOBIG message, the connected UDP socket will get EMSGSIZE
> message on its next read from the socket.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Wei.
