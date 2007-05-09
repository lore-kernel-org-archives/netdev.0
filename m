From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re:
 ppp_generic: fix lockdep warning
Date: Wed, 09 May 2007 02:32:24 -0700 (PDT)
Message-ID: <20070509.023224.31601789.davem@davemloft.net>
References: <20070426.013911.69219176.davem@davemloft.net>
	<20070426104950.GA3145@ff.dom.local>
	<20070509093536.GA2436@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jura@netams.com, akpm@linux-foundation.org, netdev@vger.kernel.org,
	paulus@samba.org, greearb@candelatech.com, mostrows@speakeasy.net
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754927AbXEIKA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 06:00:57 -0400
In-Reply-To: <20070509093536.GA2436@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Wed, 9 May 2007 11:35:37 +0200

> After rethinking there is the 3-rd way (as usual):
> 
> c) vlan should use different lockdep lock subclasses or
> classes for different types of devices, used at the same
> time.

Perhaps we should just bite the bullet and use a seperate
unique lock class for ->_xmit_lock of each device type.

We are going to find more cases like this one, for sure.

