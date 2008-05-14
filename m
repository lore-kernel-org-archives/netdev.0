From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/8] linux/atm_tcp.h linux/atm.h: cleanup for userspace
Date: Wed, 14 May 2008 16:41:28 -0700 (PDT)
Message-ID: <20080514.164128.207245858.davem@davemloft.net>
References: <200805142319.m4ENJhts026557@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vapier@gentoo.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754075AbYENXle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:41:34 -0400
In-Reply-To: <200805142319.m4ENJhts026557@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 14 May 2008 16:19:42 -0700

> From: Mike Frysinger <vapier@gentoo.org>
> 
> The atm_tcp.h uses types from linux/atm.h, but does not include it.  It
> should also use the standard __u## types from linux/types.h rather than
> the uint##_t types since the former can be found with the kernel already.
> 
> Same goes for linux/atm.h.  The linux/socket.h include there also gets
> dropped as atm.h does not actually use anything from socket.h.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
