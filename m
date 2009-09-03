From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 02 Sep 2009 23:45:09 -0700 (PDT)
Message-ID: <20090902.234509.34851763.davem@davemloft.net>
References: <20090902120540.34e2a198@nehalam>
	<20090902.225108.168195116.davem@davemloft.net>
	<20090902233410.19f0705b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbZICGoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:44:54 -0400
In-Reply-To: <20090902233410.19f0705b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Sep 2009 23:34:10 -0700

> I doubt it would make a noticeable performance difference because
> the first memset would incur the cache penalty of the write (if any)
> and later update of fields would be cached.

Indeed, but it also means your store buffer usage is half as effective.
And when writing a ton of messages that might be important.

