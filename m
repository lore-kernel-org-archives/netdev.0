From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 17:23:43 +0200
Message-ID: <1340897023.13187.109.camel@edumazet-glaptop>
References: <20120627111152.GA2531@raven>
	 <1340866572.26242.312.camel@edumazet-glaptop>
	 <1340873862.13187.5.camel@edumazet-glaptop>
	 <1340882551.13187.96.camel@edumazet-glaptop> <20120628143302.GB2507@raven>
	 <1340895642.13187.107.camel@edumazet-glaptop> <20120628152010.GC2507@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35897 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab2F1PXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 11:23:52 -0400
Received: by eaak11 with SMTP id k11so857581eaa.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 08:23:50 -0700 (PDT)
In-Reply-To: <20120628152010.GC2507@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 16:20 +0100, Tom Parkin wrote:

> Ha, yes, fair enough ;-)
> 
> FWIW, I'm no longer seeing splat #1 from my previous report, but I do
> still see splat #2.  Since they both ended up tripping over in
> l2tp_xmit_skb() I had assumed they were symptoms of the same root
> cause -- my mistake.
> 

Fixing the #2 issue should be easy, I think.

I'll send an official submission asap for #1

thanks
