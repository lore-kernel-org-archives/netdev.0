From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 5/7] net-tcp: Fast Open client -
 sendmsg(MSG_FASTOPEN)
Date: Wed, 18 Jul 2012 23:30:09 +0200
Message-ID: <1342647009.2626.3713.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-6-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63395 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab2GRVaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:30:22 -0400
Received: by yenl2 with SMTP id l2so2113402yen.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:30:22 -0700 (PDT)
In-Reply-To: <1342645307-17772-6-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> sendmsg() (or sendto()) with MSG_FASTOPEN is a combo of connect(2)
> and write(2). The application should replace connect() with it to
> send data in the opening SYN packet.
> 

> index 25d6322..90297db 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -276,6 +276,7 @@ struct ucred {
>  #else
>  #define MSG_CMSG_COMPAT	0		/* We never have 32 bit fixups */
>  #endif
> +#define MSG_FASTOPEN	0x20000000 /* Send data in TCP SYN */

Could you put MSG_FASTOPEN before MSG_CMSG_CLOEXEC ?
