From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bluetooth : use lockdep sub-classes for diffrent
 bluetooth protocol
Date: Wed, 02 Apr 2008 00:00:06 -0700 (PDT)
Message-ID: <20080402.000006.218698845.davem@davemloft.net>
References: <20080402055956.GA3050@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	marcel@holtmann.org
To: hidave.darkstar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47893
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756094AbYDBHAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:00:06 -0400
In-Reply-To: <20080402055956.GA3050@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Young <hidave.darkstar@gmail.com>
Date: Wed, 2 Apr 2008 13:59:56 +0800

> 'rfcomm connect' will trigger lockdep warnings which is caused by
> locking diffrent kinds of bluetooth sockets at the same time.
> 
> So using sub-classes per AF_BLUETOOTH sub-type for lockdep.
> 
> Thanks for the hints from dave jones.

Applied, thanks for following up on this Dave.
