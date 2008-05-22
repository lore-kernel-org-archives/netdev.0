From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Thu, 22 May 2008 10:41:45 -0700 (PDT)
Message-ID: <20080522.104145.193700531.davem@davemloft.net>
References: <4824D1E1.10007@sun.com>
	<20080509.154538.28321777.davem@davemloft.net>
	<4835A007.7020601@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753476AbYEVRlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 13:41:50 -0400
In-Reply-To: <4835A007.7020601@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Thu, 22 May 2008 18:32:07 +0200

> Does this mean that I can expect every 10G card to have this limitation
> under Linux?

For now, yes.  The transmit path itself in the generic network
device layer is where the serialization comes from.

I'm travelling now for 3 weeks so I won't be able to work on
this stuff until I get back.
