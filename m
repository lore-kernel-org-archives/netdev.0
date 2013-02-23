From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] sock_diag: Fix out-of-bounds access to
 sock_diag_handlers[]
Date: Sat, 23 Feb 2013 09:35:39 -0800
Message-ID: <1361640939.6781.3.camel@edumazet-glaptop>
References: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
	 <1361618028-9024-2-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:39135 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756951Ab3BWRfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 12:35:43 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so844088dal.15
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 09:35:42 -0800 (PST)
In-Reply-To: <1361618028-9024-2-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-23 at 12:13 +0100, Mathias Krause wrote:
> Userland can send a netlink message requesting SOCK_DIAG_BY_FAMILY
> with a family greater or equal then AF_MAX -- the array size of
> sock_diag_handlers[]. The current code does not test for this
> condition therefore is vulnerable to an out-of-bound access opening
> doors for a privilege escalation.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
>  net/core/sock_diag.c |    3 +++
>  1 file changed, 3 insertions(+)

Thanks for fixing this.

It seems trinity didnt catch it !

Acked-by: Eric Dumazet <edumazet@google.com>
