From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 08 Sep 2010 08:24:54 -0700 (PDT)
Message-ID: <20100908.082454.104076446.davem@davemloft.net>
References: <20100906.223010.173858342.davem@davemloft.net>
	<1283859552.2338.402.camel@edumazet-laptop>
	<AANLkTind7xGeYWOOdf1xnsZoJ5aFaChpD=fU7yFU2f-T@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: leandroal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873Ab0IHPYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:24:37 -0400
In-Reply-To: <AANLkTind7xGeYWOOdf1xnsZoJ5aFaChpD=fU7yFU2f-T@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ツ Leandro Melo de Sales <leandroal@gmail.com>
Date: Wed, 8 Sep 2010 11:06:43 -0300

>    Good. I have tested and it is working... This is the exactly
> translation for code what I mentioned. Very nice...
> 
>    Will this patch be applied?

No because the patch is wrong, see the rest of the discussion.

That line Eric is removing in his patch needs to be there
because it is part of our implementation of sender side
Silly Window Syndrome avoidance.

We'll have to fix this another way.
