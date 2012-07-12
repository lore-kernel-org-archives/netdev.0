From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH 02/16] ipv4: Deliver ICMP redirects to sockets too.
Date: Fri, 13 Jul 2012 00:21:40 +0900
Message-ID: <20120713002140.a441cc979fbdaa505dda2fbe@gmail.com>
References: <20120712.011049.831106026936792516.davem@davemloft.net>
	<20120712235837.4d611326830a16f9a035dd75@gmail.com>
	<20120712.080653.1463195798230664640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47440 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558Ab2GLPVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:21:44 -0400
Received: by gglu4 with SMTP id u4so2523225ggl.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 08:21:43 -0700 (PDT)
In-Reply-To: <20120712.080653.1463195798230664640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jul 2012 08:06:53 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Date: Thu, 12 Jul 2012 23:58:37 +0900
> 
> > So, I think avobe deleted checks about skb->len need to move to
> > ping_err() in case of packets are malformed.
> 
> You would be wrong, the check belongs in icmp_socket_deliver().

Ah, OK. Thanks ;)
