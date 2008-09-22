From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 22:06:05 -0700 (PDT)
Message-ID: <20080921.220605.129235191.davem@davemloft.net>
References: <20080922041929.GA20165@2ka.mipt.ru>
	<20080921.212724.193719407.davem@davemloft.net>
	<20080922044051.GA583@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbYIVFGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 01:06:17 -0400
In-Reply-To: <20080922044051.GA583@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 22 Sep 2008 08:40:52 +0400

> Why sendfile() should be completely different compared to stream case?

Because datagram sockets are completely different from stream sockets.

You program them differently, segmentation is made by the socket user
not within by the protocol itself.

sendfile() should behave in a way congruent to the other data transfer
APIs of the BSD socket layer.
