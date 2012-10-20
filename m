From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: add SYN/data info to TCP_INFO
Date: Fri, 19 Oct 2012 22:11:03 -0400
Message-ID: <CADVnQy=hhh8LsqX-P1YUP0+qTGLJ7uvx3MOsYPRTVF6GifjQ3w@mail.gmail.com>
References: <1350695684-26962-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:56146 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759449Ab2JTCLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 22:11:04 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so1554360iea.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 19:11:04 -0700 (PDT)
In-Reply-To: <1350695684-26962-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 9:14 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Add a bit TCPI_OPT_SYN_DATA (32) to the socket option TCP_INFO:tcpi_options.
> It's set if the data in SYN (sent or received) is acked by SYN-ACK. Server or
> client application can use this information to check Fast Open success rate.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
