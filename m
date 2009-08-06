From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] appletalk: fix atalk_getname() leak
Date: Thu, 06 Aug 2009 13:17:22 -0700 (PDT)
Message-ID: <20090806.131722.53716875.davem@davemloft.net>
References: <4A7ACC3F.9070600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756084AbZHFURN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:17:13 -0400
In-Reply-To: <4A7ACC3F.9070600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Aug 2009 14:27:43 +0200

> atalk_getname() can leak 8 bytes of kernel memory to user
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6
