From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] qlge:Changing netdev msg level to default debug
Date: Tue, 24 Jan 2012 15:38:37 -0500 (EST)
Message-ID: <20120124.153837.905415925299369179.davem@davemloft.net>
References: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467Ab2AXUil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:38:41 -0500
In-Reply-To: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Mon, 23 Jan 2012 15:38:52 -0800

> Driver was passing -1 so that custom default get used but which
> makes it even more sane than 15 which was excessively verbose
> printing an unusual amount of messages.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Please don't move this code away from the canonical way in which
default message levels are handled.

The canonical way is to specify a module param that starts with the
value "-1" which when passed as the first argument to netif_msg_init()
means "use the default mask" which is the second argument.

Moving to a default of "3" makes no sense at all, express the default
in the second argument of netif_msg_init(), not the first.

I'm not applying this patch, use other drivers such as tg3.c as a
guide.
