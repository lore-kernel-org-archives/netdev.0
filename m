From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/16] [XFRM] netlink: Use nlmsg_new() and type-safe
 size calculation helpers
Date: Wed, 22 Aug 2007 13:57:48 -0700 (PDT)
Message-ID: <20070822.135748.98421363.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145630.911737091@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933692AbXHVU5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:57:50 -0400
In-Reply-To: <20070822145630.911737091@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:46 +0200

> Moves all complex message size calculation into own inlined helper
> functions and makes use of the type-safe netlink interface.
> 
> Using nlmsg_new() simplifies the calculation itself as it takes care
> of the netlink header length by itself.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
