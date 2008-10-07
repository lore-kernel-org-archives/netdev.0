From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 13:55:48 -0700 (PDT)
Message-ID: <20081007.135548.56141000.davem@davemloft.net>
References: <m37i8k3hv1.fsf@ursa.amorsen.dk>
	<48EB5D28.7000503@cosmosbay.com>
	<20081007160729.60c076c4@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, benny+usenet@amorsen.dk, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbYJGU4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 16:56:12 -0400
In-Reply-To: <20081007160729.60c076c4@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 7 Oct 2008 16:07:29 +0200

> The idea of keeping chains short is the problem. That code should
> just be pulled because it doesn't help that much, and also creates
> bias on the port randomization.

I have that patch from Vitaly Mayatskikh which does exactly this.

I keep looking at it, but I can't bring myself to apply it since
I'm not completely convinced.
