From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: add missing socket check in can/raw release
Date: Wed, 20 Apr 2011 12:22:30 -0700 (PDT)
Message-ID: <20110420.122230.116395476.davem@davemloft.net>
References: <4DAECA1B.5050300@hartkopp.net>
	<20110420170333.GD24930@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753441Ab1DTTXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:23:04 -0400
In-Reply-To: <20110420170333.GD24930@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 20 Apr 2011 13:03:34 -0400

> On Wed, Apr 20, 2011 at 01:57:15PM +0200, Oliver Hartkopp wrote:
>  > v2: added space after 'if' according code style.
>  > 
>  > We can get here with a NULL socket argument passed from userspace,
>  > so we need to handle it accordingly.
>  > 
>  > Thanks to Dave Jones pointing at this issue in net/can/bcm.c
>  > 
>  > Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> ACK. That was the first thing I hit this morning ;-)

Aha, so this patch fixes the same bug in a different part of CAN,
I missed that :-)

Ok I'll apply this, thanks!
