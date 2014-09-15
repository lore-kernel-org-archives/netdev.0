From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 2/3] tcp: allow segment with FIN in tcp_try_coalesce()
Date: Mon, 15 Sep 2014 12:20:37 -0400
Message-ID: <CADVnQykwtVycYjTeg-j+UsDvp3Z7wS6JxUCM3q8ut=UojiuVwg@mail.gmail.com>
References: <1410779993-31464-1-git-send-email-edumazet@google.com>
	<1410779993-31464-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:47456 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbaIOQUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:20:41 -0400
Received: by mail-qa0-f49.google.com with SMTP id i13so4056801qae.8
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:20:38 -0700 (PDT)
In-Reply-To: <1410779993-31464-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 7:19 AM, Eric Dumazet <edumazet@google.com> wrote:
> We can allow a segment with FIN to be aggregated,
> if we take care to add tcp flags,
> and if skb_try_coalesce() takes care of zero sized skbs.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
