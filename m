From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix nl group when advertising a new link
Date: Fri, 10 Dec 2010 12:49:52 -0800 (PST)
Message-ID: <20101210.124952.200360340.davem@davemloft.net>
References: <4CFF5217.6010601@6wind.com>
	<20101208100454.GA7638@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756851Ab0LJUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:49:24 -0500
In-Reply-To: <20101208100454.GA7638@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Wed, 8 Dec 2010 05:04:54 -0500

> On Wed, Dec 08, 2010 at 10:38:31AM +0100, Nicolas Dichtel wrote:
>> >From d2ed52e7fcb639470c89045f7b0ce31eb681896a Mon Sep 17 00:00:00 2001
>> From: Wang Xuefu <xuefu.wang@6wind.com>
>> Date: Wed, 8 Dec 2010 10:24:48 +0100
>> Subject: [PATCH] ipv6: fix nl group when advertising a new link
>> 
>> New idev are advertised with NL group RTNLGRP_IPV6_IFADDR, but
>> should use RTNLGRP_IPV6_IFINFO.
>> Bug was introduced by commit 8d7a76c9.
>> 
>> Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Acked-by: Thomas Graf <tgraf@infradead.org>

Applied to net-2.6, thanks.
