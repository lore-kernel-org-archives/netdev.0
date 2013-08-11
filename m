From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with
 fragmented memory
Date: Sun, 11 Aug 2013 07:42:16 -0700
Message-ID: <1376232136.3291.1.camel@edumazet-glaptop>
References: <1375997852.4004.130.camel@edumazet-glaptop>
	 <20130811140605.GA5666@order.stressinduktion.org>
	 <1376231553.3291.0.camel@edumazet-glaptop>
	 <20130811143715.GA3699@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:40508 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721Ab3HKOma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 10:42:30 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2367228pdj.8
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 07:42:29 -0700 (PDT)
In-Reply-To: <20130811143715.GA3699@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-11 at 16:37 +0200, Hannes Frederic Sowa wrote:
> On Sun, Aug 11, 2013 at 07:32:33AM -0700, Eric Dumazet wrote:
> > On Sun, 2013-08-11 at 16:06 +0200, Hannes Frederic Sowa wrote:
> > 
> > > I am sorry to report that I had to revert both these patches to have a working
> > > systemd again.
> > 
> > Hi Hannes
> > 
> > If you revert only the second patch, the problem is still there, right ?
> 
> Exactly, only reverting 2/2 did not help.

I wonder if the consumed field (part of skb->cb{}) would not be zero ?

I assumed it was. I have to check.
