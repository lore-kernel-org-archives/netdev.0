From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: don't include Fast Open option in SYN-ACK on
 pure SYN-data
Date: Thu, 5 Feb 2015 19:58:27 -0500
Message-ID: <CADVnQy=aOGWn2CA07KYLkbcsLB6_8-bncnLaJ+BNcQ516b0c8g@mail.gmail.com>
References: <1423183446-15280-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:37759 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbBFA61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:58:27 -0500
Received: by mail-qa0-f41.google.com with SMTP id bm13so8641091qab.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:58:27 -0800 (PST)
In-Reply-To: <1423183446-15280-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 7:44 PM, Yuchung Cheng <ycheng@google.com> wrote:
> If a server has enabled Fast Open and it receives a pure SYN-data
> packet (without a Fast Open option), it won't accept the data but it
> incorrectly returns a SYN-ACK with a Fast Open cookie and also
> increments the SNMP stat LINUX_MIB_TCPFASTOPENPASSIVEFAIL.
>
> This patch makes the server include a Fast Open cookie in SYN-ACK
> only if the SYN has some Fast Open option (i.e., when client
> requests or presents a cookie).
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_fastopen.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
