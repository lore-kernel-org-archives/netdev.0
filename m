From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] sit: fix use after free of fb_tunnel_dev
Date: Wed, 13 Nov 2013 21:58:17 -0500
Message-ID: <CA+FuTSf=oEQQ9R5t7RQ0aJwvqUJ==nZuOR3fY=HySCRuVnxm1g@mail.gmail.com>
References: <1384396058-26850-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:34419 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3KNC6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:58:48 -0500
Received: by mail-qc0-f169.google.com with SMTP id u18so849053qcx.14
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 18:58:47 -0800 (PST)
In-Reply-To: <1384396058-26850-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please also queue this patch up for 3.11 stable.

It is apparently also relevant for 3.10. That is the only other stable
branch that has the mentioned patch. This fix does not apply cleanly
there, however. Only the top half is required. Applying that does
appear to resolve the problem.

And I forgot to mention the actual test: `modprobe sit; rmmod sit`
