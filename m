From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Add CONFIG_INET dependency to
 CONFIG_XFRM_STATISTICS
Date: Fri, 15 Feb 2008 15:24:00 -0800 (PST)
Message-ID: <20080215.152400.65001698.davem@davemloft.net>
References: <1203088123.29269.1.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johfel@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753856AbYBOXXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 18:23:31 -0500
In-Reply-To: <1203088123.29269.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@gmx.de>
Date: Fri, 15 Feb 2008 16:08:43 +0100

> From: Johann Felix Soden <johfel@users.sourceforge.net>
> 
> With INET=n and XFRM_STATISTICS=y I get the following build failure:
> 
> net/built-in.o: In function `xfrm_init':
> (.init.text+0xcd7): undefined reference to `snmp_mib_init'
> 
> Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
> CC: Masahide NAKAMURA <nakam@linux-ipv6.org>

A fix for this has been in my net-2.6 tree for a few days,
and Linus pulled it in this morning.
