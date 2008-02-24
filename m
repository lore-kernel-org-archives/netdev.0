From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c:95!
Date: Sat, 23 Feb 2008 20:01:30 -0800 (PST)
Message-ID: <20080223.200130.119882236.davem@davemloft.net>
References: <20080221054648.GU84358@surrealistic.net>
	<20080220.215707.194209573.davem@davemloft.net>
	<20080221191352.GV84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: jwestfall@surrealistic.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753036AbYBXEAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 23:00:49 -0500
In-Reply-To: <20080221191352.GV84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Westfall <jwestfall@surrealistic.net>
Date: Thu, 21 Feb 2008 11:13:52 -0800

> > 
> > 2) Second, skb_realloc_headroom() is called on 'skb' with
> >    a second argument of 'dsize'.
> 
> This suggestion escapes me.  The skb_put() call in the above 
> code would increase skb->tail.  Wont skb_realloc_headroom() create 
> additional space between skb->head and skb->data when we really want it 
> between skb->tail and skb->end?

My bad, you need to increase the tailroom not the headroom.
