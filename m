From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/7] net-tcp: Fast Open base
Date: Wed, 18 Jul 2012 23:16:10 +0200
Message-ID: <1342646170.2626.3693.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:46912 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab2GRVQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:16:21 -0400
Received: by ghrr11 with SMTP id r11so2099618ghr.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:16:20 -0700 (PDT)
In-Reply-To: <1342645307-17772-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> This patch impelements the common code for both the client and server.
> 
> 1. TCP Fast Open option processing. Since Fast Open does not have an
>    option number assigned by IANA yet, it shares the experiment option
>    code 254 by implementing draft-ietf-tcpm-experimental-options
>    with a 16 bits magic number 0xF989. This enables global experiments
>    without clashing the scarce(2) experimental options available for TCP.
> 
>    When the draft status becomes standard (hopefully), the client should
>    switch to the new option number assigned while the server supports
>    both numbers for transistion.
> 
> 2. The new sysctl tcp_fastopen
> 
> 3. A place holder init function
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
