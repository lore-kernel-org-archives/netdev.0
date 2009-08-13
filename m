From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.31-rc5] can: fix oops caused by wrong rtnl newlink
 usage
Date: Thu, 13 Aug 2009 16:33:17 -0700 (PDT)
Message-ID: <20090813.163317.254848808.davem@davemloft.net>
References: <4A8166F4.6040204@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, wg@grandegger.com, netdev@vger.kernel.org,
	dbaryshkov@gmail.com
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbZHMXdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:33:06 -0400
In-Reply-To: <4A8166F4.6040204@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 11 Aug 2009 14:41:24 +0200

> For 'real' hardware CAN devices the netlink interface is used to set CAN
> specific communication parameters. Real CAN hardware can not be created with
> the ip tool ...
> 
> The invocation of 'ip link add type can' lead to an oops as the standard rtnl
> newlink function was called:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=13954
> 
> This patch adds a private newlink function for the CAN device driver interface
> that unconditionally returns -EOPNOTSUPP.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Reported-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

Applied to net-2.6
