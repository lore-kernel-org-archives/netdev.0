From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Rename struct net to struct netns
Date: Mon, 17 Sep 2007 09:42:00 -0700 (PDT)
Message-ID: <20070917.094200.59657046.davem@davemloft.net>
References: <46EE932F.2030206@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751333AbXIQQmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 12:42:06 -0400
In-Reply-To: <46EE932F.2030206@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 17 Sep 2007 18:46:07 +0400

> The name struct net is too generic. There already were
> some people who wanted to have some better name (for
> easier grep for example). I propose the struct netns one.

I don't see any reason to change the name, 'net' is just
fine with me.  It's in the struct/union namespace so even
if you use a variable or a function with the same name
it's unambiguous.

If C would allow it we'd be using 'if' instead of 'netdevice'
as well :-)
