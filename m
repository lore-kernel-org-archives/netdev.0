From: Cong Wang <cwang@twopensource.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Mon, 13 Oct 2014 16:59:57 -0700
Message-ID: <CAHA+R7OWpjO0AbwteOAfxd1fej6BcjXR99xy+MnkZ8y+JZ8f4g@mail.gmail.com>
References: <543AB655.6060603@winsoft.pl>
	<1413139613.9362.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>,
	netdev <netdev@vger.kernel.org>, edumazet@gmail.com,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:50915 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbaJMX76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 19:59:58 -0400
Received: by mail-qc0-f178.google.com with SMTP id c9so5969269qcz.9
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 16:59:57 -0700 (PDT)
In-Reply-To: <1413139613.9362.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably not related with this bug, but with regarding to the
offending commit, what's the point of the memmove() in tcp_v4_rcv()
since ip_rcv() already clears IPCB()?
