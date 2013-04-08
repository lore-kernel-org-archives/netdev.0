From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 11:21:43 -0700
Message-ID: <1365445303.3887.33.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <1558855.HGIqa4tJdt@sifl> <1365443267.3887.28.camel@edumazet-glaptop>
	 <1725553.maWFXblPLa@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57755 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934699Ab3DHSVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:21:48 -0400
Received: by mail-ie0-f180.google.com with SMTP id a11so7247530iee.25
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:21:46 -0700 (PDT)
In-Reply-To: <1725553.maWFXblPLa@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:

> 
> It seems a bit fragile to me, perhaps even hacky, but in some ways I guess it 
> isn't anymore fragile than relying on skb->sk - as this problem demonstrates.  
> My other concern is that adding this hook *correctly* is likely to touch a lot 
> of files and may be a bit much so late in the 3.9 cycle, Dave, what say you?

I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
3.9 ?

I am preparing a fix right now. Not a revert, thank you.
