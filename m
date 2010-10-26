From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 11:23:21 -0700 (PDT)
Message-ID: <20101026.112321.258116003.davem@davemloft.net>
References: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
	<20101026.104710.232747902.davem@davemloft.net>
	<AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334Ab0JZSW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:22:58 -0400
In-Reply-To: <AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 11:17:27 -0700

> This works pretty well. Why not do the same for IPv6? The only
> difference in IPv6 is that the kernel is the one doing
> autoconfiguration, so it's the kernel that should be doing the asking.

That should be fine, but if I have static IPv6 addresses assigned to
an interface I really don't want them changing on a simple link flap.
