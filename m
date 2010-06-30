From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] fragment: add fast path for in-order fragments
Date: Wed, 30 Jun 2010 13:44:51 -0700 (PDT)
Message-ID: <20100630.134451.141232923.davem@davemloft.net>
References: <1277822377-742-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, erblichs@earthlink.net
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380Ab0F3Uoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:44:39 -0400
In-Reply-To: <1277822377-742-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 29 Jun 2010 22:39:37 +0800

> add fast path for in-order fragments
> 
> As the fragments are sent in order in most of OSes, such as Windows, Darwin and
> FreeBSD, it is likely the new fragments are at the end of the inet_frag_queue.
> In the fast path, we check if the skb at the end of the inet_frag_queue is the
> prev we expect.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
