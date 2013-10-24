From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: Don't free f before it is allocated in
 route4_change
Date: Thu, 24 Oct 2013 08:05:57 -0700
Message-ID: <1382627157.7572.59.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382626250-15676-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1382626473.7572.58.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131024145936.GB15936@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jing Wang <windsdaemon@gmail.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37962 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3JXPGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:06:01 -0400
Received: by mail-wi0-f174.google.com with SMTP id cb5so9165287wib.1
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 08:06:00 -0700 (PDT)
In-Reply-To: <20131024145936.GB15936@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 16:59 +0200, Christoph Paasch wrote:
> On 24/10/13 - 07:54:33, Eric Dumazet wrote:

> > I see no bug here, you missed the "goto reinsert;"
> 
> Ups - sorry...
> 

Yeah, trying to find bugs in Alexey code is really tricky ;)
