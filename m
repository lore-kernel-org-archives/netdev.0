From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp/ipv6: fix flow label setting in TIME_WAIT state
Date: Sun, 17 May 2015 19:48:29 -0700
Message-ID: <1431917309.621.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431728699-7767-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34200 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbERCsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:48:31 -0400
Received: by igbhj9 with SMTP id hj9so1868519igb.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 19:48:31 -0700 (PDT)
In-Reply-To: <1431728699-7767-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-05-16 at 00:24 +0200, Florent Fourcot wrote:
> commit 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages
> send from TIME_WAIT") added the flow label in the last TCP packets.
> Unfortunately, it was not casted properly.
> 
> This patch replace the buggy shift with be32_to_cpu/cpu_to_be32.
> 
> Fixes: 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Merci Florent !
