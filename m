From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink.c: send a single notification on device
 state changes
Date: Tue, 12 Feb 2008 22:42:52 -0800 (PST)
Message-ID: <20080212.224252.03600088.davem@davemloft.net>
References: <20080205.175337.266368079.davem@davemloft.net>
	<1202385470416-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753119AbYBMGmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:42:20 -0500
In-Reply-To: <1202385470416-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laszlo Attila Toth <panther@balabit.hu>
Date: Thu,  7 Feb 2008 12:57:50 +0100

> In do_setlink() a single notification is sent at the end of the function
> if any modification occured. If the address has been changed, another
> notification is sent.
> 
> Both of them is required because originally only the NETDEV_CHANGEADDR
> notification was sent and although device state change implies address
> change, some programs may expect the original notification. It remains
> for compatibity.
> 
> If set_operstate() is called from do_setlink(), it doesn't send
> a notification, only if it is called from rtnl_create_link() as earlier.
> 
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

Looks good, applied.

Let's hope this doesn't break some stupid application
unintentionally.
