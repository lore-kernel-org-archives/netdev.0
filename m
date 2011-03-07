From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 07 Mar 2011 13:49:31 -0800 (PST)
Message-ID: <20110307.134931.232736253.davem@davemloft.net>
References: <20110307213648.GA18682@mtldesk30>
	<20110307.134001.245386278.davem@davemloft.net>
	<20110307214812.GA19540@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756509Ab1CGVsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:48:53 -0500
In-Reply-To: <20110307214812.GA19540@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Mon, 7 Mar 2011 23:48:12 +0200

> On Mon, Mar 07, 2011 at 01:40:01PM -0800, David Miller wrote:
>> From: Eli Cohen <eli@dev.mellanox.co.il>
>> Date: Mon, 7 Mar 2011 23:36:48 +0200
>> 
>> > Specifically, some archs may not support write combining.
>> 
>> They should just create a non-write-combining mapping if they
>> don't support it.
>> 
> 
> I wouldn't expect that since the caller function could be mislead to
> believe it has a write combining capable area.

It's a performance optimization, if you don't get write combining you'll
get more strict ordering, rather than less.

It cannot cause problem.
