From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 4/7] net-tcp: Fast Open client - receiving SYN-ACK
Date: Wed, 18 Jul 2012 23:27:37 +0200
Message-ID: <1342646857.2626.3710.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-5-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47291 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750Ab2GRV1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:27:46 -0400
Received: by gglu4 with SMTP id u4so2107734ggl.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:27:46 -0700 (PDT)
In-Reply-To: <1342645307-17772-5-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> On receiving the SYN-ACK after SYN-data, the client needs to
> a) update the cached MSS and cookie (if included in SYN-ACK)
> b) retransmit the data not yet acknowledged by the SYN-ACK in the final ACK of
>    the handshake.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
