From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Avoid problems with bonding and device rename
Date: Wed, 14 May 2008 17:07:09 -0700 (PDT)
Message-ID: <20080514.170709.190178519.davem@davemloft.net>
References: <20080514170316.672f809d@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751001AbYEOAHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 20:07:16 -0400
In-Reply-To: <20080514170316.672f809d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 14 May 2008 17:03:16 -0700

> See: http://bugzilla.kernel.org/show_bug.cgi?id=10698
> 
> The use of /sys/class/net/bonding_masters was a poor ABI choice
> that now we have to live with. Best choice is to just block other
> usage of that name.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I think sysfs is way too noisy in this case and we should
handle the sysfs add failure just like any other -EEXIST case.
