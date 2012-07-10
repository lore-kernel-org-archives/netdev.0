From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 12:18:30 +0200
Message-ID: <1341915510.3265.4734.camel@edumazet-glaptop>
References: <4FFBFBD2.6030004@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54960 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2GJKSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 06:18:36 -0400
Received: by eaak11 with SMTP id k11so4619694eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 03:18:34 -0700 (PDT)
In-Reply-To: <4FFBFBD2.6030004@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 12:54 +0300, Or Gerlitz wrote:
> Hi Dave, Eric,
> 
> Another trace that I see here with net-next is this one-time warning. I 
> get it always
> on the passive side of TCP, something that seems related to GRO, it 
> happens only with
> IPoIB, not with mlx4_en and igb (when igb get to work on net-next...)
> 
> The latest commit in this area is bad43ca8325f493dcaa0896c2f036276af059c7e
> "net: introduce skb_try_coalesce()" from Eric.
> 
> Or.
> 
> -----------[ cut here ]------------
> WARNING: at net/core/skbuff.c:3413 skb_try_coalesce+0x1f8/0x31d()

This warning catch skb truesize offenders, most probably its a driver
issue.
