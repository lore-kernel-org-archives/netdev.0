From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Network Events Connector
Date: Mon, 02 Oct 2006 13:33:14 -0700 (PDT)
Message-ID: <20061002.133314.41657633.davem@davemloft.net>
References: <m23ba7gscl.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29931
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964990AbWJBUdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 16:33:02 -0400
To: sbellabes@mandriva.com
In-Reply-To: <m23ba7gscl.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sbellabes@mandriva.com>
Date: Mon, 02 Oct 2006 08:11:06 +0200

> This patch adds a connector which reports networking's events to
> userspace. It's sending events when a sock has its sk_state changed to :
>   - LISTEN or CLOSE for DCCP and TCP
>   - BIND or CLOSE for UDP.
> 
> With this notification, a userspace tool can ask the user if he want to
> let the local firewall open for the corresponding sport or not, and if
> so open the firewall for the application which get the corresponding sport.

You can do this with the security layer, netfilter's ULOG, or even
the netfilter connection tracking netlink sockets.

That's 3 facilities by which you can accomplish this, and if none
of them are perfect, add the small modifications you need to one
of them to make them usable for your task.

It makes no sense to add new facilities just for this.

