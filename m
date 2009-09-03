From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 02 Sep 2009 22:51:26 -0700 (PDT)
Message-ID: <20090902.225126.84085775.davem@davemloft.net>
References: <4A9E67A9.7090205@gmail.com>
	<20090902180935.GA2849@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754331AbZICFvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 01:51:11 -0400
In-Reply-To: <20090902180935.GA2849@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 2 Sep 2009 20:09:36 +0200

> Wed, Sep 02, 2009 at 02:40:09PM CEST, eric.dumazet@gmail.com wrote:
>>Three bytes of uninitialized kernel memory are currently leaked to user
>>
>>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

I'll apply this to net-2.6, thanks everyone.
