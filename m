From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Sun, 04 Oct 2015 08:50:02 -0400
Message-ID: <8737xq3iit.fsf@bytheb.org>
References: <1443733536-992-1-git-send-email-avagin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Andrey Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33746 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbJDMuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:50:06 -0400
Received: by qkas79 with SMTP id s79so60087031qka.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:50:05 -0700 (PDT)
In-Reply-To: <1443733536-992-1-git-send-email-avagin@gmail.com> (Andrey
	Vagin's message of "Fri, 2 Oct 2015 00:05:36 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Vagin <avagin@gmail.com> writes:

> From: Andrey Vagin <avagin@openvz.org>
>
> Now send with MSG_PEEK can return data from multiple SKBs.
>
> Unfortunately we take into account the peek offset for each skb,
> that is wrong. We need to apply the peek offset only once.
>
> In addition, the peek offset should be used only if MSG_PEEK is set.
>
> Cc: "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
> Cc: Eric Dumazet <edumazet@google.com> (commit_signer:1/14=7%)
> Cc: Aaron Conole <aconole@bytheb.org>
> Fixes: 9f389e35674f ("af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag")
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
Tested-by: Aaron Conole <aconole@bytheb.org>

Thanks again!
