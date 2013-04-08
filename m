From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 11:01:55 -0700
Message-ID: <1365444115.3887.30.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <3541094.5siDbVn1lC@sifl> <1365442586.3887.26.camel@edumazet-glaptop>
	 <1558855.HGIqa4tJdt@sifl> <1365443267.3887.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:64766 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762858Ab3DHSHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 14:07:42 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so2713339dad.32
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 11:07:42 -0700 (PDT)
In-Reply-To: <1365443267.3887.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 10:47 -0700, Eric Dumazet wrote:

> This kind of requirement has a huge cost, and thats why I want a hook
> instead of a 'generic thing'

I meant " I would like ... "

We for example have security_inet_csk_clone()

We could have security_skb_owned_by(skb, sk)

I probably can send a patch, it seems quite easy.
