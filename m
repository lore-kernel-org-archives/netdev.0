From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 3/3] tcp: do not copy headers in tcp_collapse()
Date: Mon, 15 Sep 2014 12:29:11 -0400
Message-ID: <CADVnQymPczbRdPqNPsLv0dpzwnKCHGn7mSnrTzE5-1A3WkRiqQ@mail.gmail.com>
References: <1410779993-31464-1-git-send-email-edumazet@google.com>
	<1410779993-31464-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:63633 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbaIOQ3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:29:14 -0400
Received: by mail-qc0-f174.google.com with SMTP id m20so4207248qcx.19
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:29:12 -0700 (PDT)
In-Reply-To: <1410779993-31464-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 7:19 AM, Eric Dumazet <edumazet@google.com> wrote:
> tcp_collapse() wants to shrink skb so that the overhead is minimal.
>
> Now we store tcp flags into TCP_SKB_CB(skb)->tcp_flags, we no longer
> need to keep around full headers.
> Whole available space is dedicated to the payload.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
