From: David Miller <davem@davemloft.net>
Subject: Re: can: add missing socket check in can/raw release.
Date: Wed, 20 Apr 2011 12:02:18 -0700 (PDT)
Message-ID: <20110420.120218.15220634.davem@davemloft.net>
References: <4DAEC7A0.1090103@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35578
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485Ab1DTTCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:02:53 -0400
In-Reply-To: <4DAEC7A0.1090103@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 20 Apr 2011 13:46:40 +0200

> We can get here with a NULL socket argument passed from userspace,
> so we need to handle it accordingly.
> 
> Thanks to Dave Jones pointing at this issue in net/can/bcm.c
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

I already applied Dave's patch from last night.
