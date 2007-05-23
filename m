From: David Miller <davem@davemloft.net>
Subject: Re: [FIX][PATCH] ipv6 addrconf.c REMOVED #if patch
Date: Wed, 23 May 2007 14:35:45 -0700 (PDT)
Message-ID: <20070523.143545.27952960.davem@davemloft.net>
References: <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
	<464CC4B8.6040401@hartkopp.net>
	<ygf8xbivy0s.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758310AbXEWVfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:35:42 -0400
In-Reply-To: <ygf8xbivy0s.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs@isnogud.escape.de>
Date: 21 May 2007 20:20:51 +0200

> Oliver Hartkopp <socketcan@hartkopp.net> writes:
> 
> > Yep - you were right. It looks better like this as ARPHRD_SIT is
> > defined in if_arp.h in any CONFIG_* case ...
> 
> Oliver asked me to resend the patch with a sane mailer that doesn't
> mangle white-space and line breaks.  So here it is.
> 
> This patch makes the netdevice notifier for IPv6 ignore all events on
> non-IPv6 capable devices.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

Patch applied, thank you.

