From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Thu, 08 Apr 2010 02:54:12 -0700 (PDT)
Message-ID: <20100408.025412.247148013.davem@davemloft.net>
References: <4BBC8C8F.9020907@trash.net>
	<20100407.164842.54065324.davem@davemloft.net>
	<4BBDA58B.8090301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51011
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758263Ab0DHJyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 05:54:12 -0400
In-Reply-To: <4BBDA58B.8090301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 08 Apr 2010 11:44:43 +0200

> Either the kernel or the userspace programs have to be updated
> either way.

The only case in which we only have to change one side is if we add
the full set of compat support to the kernel.

If we take any other option (new XFRM numbers and new datastructures,
or only convert sendmsg() to do compat translations), it requires both
the kernel and userspace to change.

And the currently existing 32-bit binaries don't work on 64-bit
kernels because of something that cannot be classified any other way
than as being a kernel bug.
