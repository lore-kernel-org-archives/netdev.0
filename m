From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 07:42:48 -0700
Message-ID: <1366382568.16391.0.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33987 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030720Ab3DSOmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:42:52 -0400
Received: by mail-pa0-f50.google.com with SMTP id bg2so2288216pad.23
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 07:42:51 -0700 (PDT)
In-Reply-To: <1366373950.26911.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:19 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 2013-04-19 at 03:11 -0700, Eric Dumazet wrote:

> > This strategy wont really help DDOS attacks. No frag will ever complete.
> 
> I beg to differ.

We already had a discussion on this topic.
