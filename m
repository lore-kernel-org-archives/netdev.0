From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/Makefile - question about link order comment
 introduced in 2.3.43
Date: Wed, 06 Oct 2010 13:15:45 -0700 (PDT)
Message-ID: <20101006.131545.59698295.davem@davemloft.net>
References: <1286363049.2156.113.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sam@ravnborg.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759939Ab0JFUPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 16:15:24 -0400
In-Reply-To: <1286363049.2156.113.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 06 Oct 2010 04:04:09 -0700

> It wasn't that way in 2.3.43-pre7 , but it is in 2.3.43
> and has remained there since.  There's nothing in lkml
> history as far as I can find to describe a reason for it.
> 
> http://lkml.org/lkml/2000/2/10
> (or thereabout)
> 
> Anyone know why it's like that or if that Makefile link
> ordering is still needed?

I suspect it's not needed any more.

I also suspect it's an obsolete sparc specific hack to get the primary
ethernet interface to always show up as eth0.
