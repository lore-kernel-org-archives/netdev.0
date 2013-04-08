From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 10:47:47 -0700
Message-ID: <1365443267.3887.28.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <3541094.5siDbVn1lC@sifl> <1365442586.3887.26.camel@edumazet-glaptop>
	 <1558855.HGIqa4tJdt@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:45007 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763332Ab3DHRru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 13:47:50 -0400
Received: by mail-da0-f50.google.com with SMTP id t1so2702040dae.9
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 10:47:50 -0700 (PDT)
In-Reply-To: <1558855.HGIqa4tJdt@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 13:40 -0400, Paul Moore wrote:

> Sort of a similar problem, but not really the same.  Also, arguably, there is 
> no real associated sock/socket for a RST so orphaning the packet makes sense.  
> In the case of a SYNACK we can, and should, associate the packet with a 
> sock/socket.

What is the intent ?

This kind of requirement has a huge cost, and thats why I want a hook
instead of a 'generic thing'

Please read : 

http://workshop.netfilter.org/2013/wiki/images/3/3a/NFWS-TCP.pdf
