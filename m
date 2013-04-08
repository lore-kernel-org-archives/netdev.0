From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 11:34:11 -0700
Message-ID: <1365446051.3887.37.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <1725553.maWFXblPLa@sifl> <1365445303.3887.33.camel@edumazet-glaptop>
	 <10426929.HS2uObfqRU@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f176.google.com ([209.85.210.176]:44924 "EHLO
	mail-ia0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935447Ab3DHSeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:34:16 -0400
Received: by mail-ia0-f176.google.com with SMTP id i1so5427268iaa.7
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:34:15 -0700 (PDT)
In-Reply-To: <10426929.HS2uObfqRU@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 14:26 -0400, Paul Moore wrote:

> I guess we'll have to wait and see then; the more I think about the new hook 
> you proposed the less enthused I am about it.
> 
> I'm still curious to hear what Dave has to say on this.
> 

90ba9b1986b5ac4b2 is 10 months old, and nobody complained until today ?

This sounds like a very small issue to me, a revert is simply overkill. 

Lets go forward instead of applying blind fixes.
