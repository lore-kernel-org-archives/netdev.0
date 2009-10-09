From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Fri, 09 Oct 2009 18:31:30 +0200
Message-ID: <4ACF6562.9040109@gmail.com>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw>	<4ACD585B.5080106@gmail.com> <20091007.224036.247820677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thomas@wytron.com.tw, netdev@vger.kernel.org,
	thierry.reding@avionic-design.de, nios2-dev@sopc.et.ntust.edu.tw,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43274 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933933AbZJIQcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 12:32:15 -0400
In-Reply-To: <20091007.224036.247820677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

> Looks ok, but I want to look at how often this exact sequence
> would match.  If it applies to a lot of cases, I'll add this
> but I know of many exceptions in my head already :-)

Well, it was more as a reference. I believe about 20-30 call sites
could use it. Do you want me to provide a combo patch ?

