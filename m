From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Thu, 03 Oct 2013 14:22:13 -0700
Message-ID: <1380835333.19002.231.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.153158.1558578931500427624.davem@davemloft.net>
	 <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.160252.2071364130742864278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:36349 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567Ab3JCVWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:22:16 -0400
Received: by mail-ye0-f174.google.com with SMTP id q1so122479yen.33
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 14:22:15 -0700 (PDT)
In-Reply-To: <20131003.160252.2071364130742864278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 16:02 -0400, David Miller wrote:

> I am sure that you could define a set of interfaces which are named
> such that the intent and usage is clear, would do the u32 cast, and
> would be updated by whoever changes the timestamp implementation in
> the future.
> 
> The cast is really ugly, even if we do it in inetpeer already, and
> you're already here cleaning things up, so please do it right.

Sure I will do.
