From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] Consolidate xxx_frag_alloc()
Date: Wed, 17 Oct 2007 19:45:52 -0700 (PDT)
Message-ID: <20071017.194552.44095140.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C358.50502@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755616AbXJRCpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:45:53 -0400
In-Reply-To: <4714C358.50502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 17:57:44 +0400

> Just perform the kzalloc() allocation and setup common
> fields in the inet_frag_queue(). Then return the result
> to the caller to initialize the rest.
> 
> The inet_frag_alloc() may return NULL, so check the 
> return value before doing the container_of(). This looks 
> ugly, but the xxx_frag_alloc() will be removed soon.
> 
> The xxx_expire() timer callbacks are patches, 
> because the argument is now the inet_frag_queue, not 
> the protocol specific queue.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, although I had to correct the following white-space
problems in your patch:

Adds trailing whitespace.
diff:33:	
Adds trailing whitespace.
diff:72:	
Adds trailing whitespace.
diff:126:	
warning: 3 lines add whitespace errors.
