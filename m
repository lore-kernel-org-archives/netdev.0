From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Fix the wanxl firmware to include missing constants
Date: Fri, 09 Nov 2012 16:29:26 -0500 (EST)
Message-ID: <20121109.162926.378449818232554796.davem@davemloft.net>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
	<20121107123724.4147.98542.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, linux@arm.linux.org.uk
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab2KIV33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:29:29 -0500
In-Reply-To: <20121107123724.4147.98542.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Nov 2012 12:37:24 +0000

> Fix the wanxl firmware to include missing constants such as PARITY_NONE.  It
> should be #including the linux/hdlc/ioctl.h header.
> 
> To make this work, we also have to guard parts of ioctl.h with !__ASSEMBLY__.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied to net-next.
