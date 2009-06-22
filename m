From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Fix velocity driver unmapping incorrect size.
Date: Sun, 21 Jun 2009 22:42:50 -0700 (PDT)
Message-ID: <20090621.224250.161254034.davem@davemloft.net>
References: <20090621.184345.194558005.davem@davemloft.net>
	<20090622033735.GA9923@redhat.com>
	<20090622053530.GA28382@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbZFVFmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:42:46 -0400
In-Reply-To: <20090622053530.GA28382@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 22 Jun 2009 01:35:30 -0400

> this makes it even clearer what's going on.
> -- 
> 
> When a packet is greater than ETH_ZLEN, we end up assigning the
> boolean result of a comparison to the size we unmap.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Looks great Dave, thanks for figuring this out.

I'll queue this up for -stable too.
