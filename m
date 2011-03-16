From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: Force a dst refcount before entering the
 xfrm type handlers
Date: Wed, 16 Mar 2011 00:17:32 -0700 (PDT)
Message-ID: <20110316.001732.112599674.davem@davemloft.net>
References: <20110316070828.GQ31402@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751864Ab1CPHQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 03:16:54 -0400
In-Reply-To: <20110316070828.GQ31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Steffen we really need to find another way to fix these problems.

We already make way too many expensive atomic operations in these code
paths modified by your 3 patches, we should strive to not add new
ones.

Thanks.
