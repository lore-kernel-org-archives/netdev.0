From: David Miller <davem@davemloft.net>
Subject: Re: strange tcp behavior
Date: Fri, 03 Aug 2007 14:17:17 -0700 (PDT)
Message-ID: <20070803.141717.36925406.davem@davemloft.net>
References: <20070802184840.GA8901@2ka.mipt.ru>
	<20070802.192134.107254907.davem@davemloft.net>
	<20070803082242.GA25582@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761127AbXHCVR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 17:17:26 -0400
In-Reply-To: <20070803082242.GA25582@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 3 Aug 2007 12:22:42 +0400

> Maybe recvmsg should be changed too for symmetry?

I took a look at this, and it's not %100 trivial.

Let's do this later, and only sendmsg for now in order to
fix the bug in the stable branches.
