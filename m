From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/16] [XFRM] netlink: Use nlmsg_parse() to parse
 attributes
Date: Wed, 22 Aug 2007 13:58:26 -0700 (PDT)
Message-ID: <20070822.135826.48825580.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145631.073291531@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763813AbXHVU61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:58:27 -0400
In-Reply-To: <20070822145631.073291531@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:47 +0200

> Uses nlmsg_parse() to parse the attributes. This actually changes
> behaviour as unknown attributes (type > MAXTYPE) no longer cause
> an error. Instead unknown attributes will be ignored henceforth
> to keep older kernels compatible with more recent userspace tools.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
