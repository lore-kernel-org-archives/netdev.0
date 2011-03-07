From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 07 Mar 2011 14:09:12 -0800 (PST)
Message-ID: <20110307.140912.35052431.davem@davemloft.net>
References: <20110307214812.GA19540@mtldesk30>
	<20110307.134931.232736253.davem@davemloft.net>
	<20110307215803.GB19540@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753067Ab1CGWIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 17:08:34 -0500
In-Reply-To: <20110307215803.GB19540@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Mon, 7 Mar 2011 23:58:03 +0200

> On Mon, Mar 07, 2011 at 01:49:31PM -0800, David Miller wrote:
>> 
>> It's a performance optimization, if you don't get write combining you'll
>> get more strict ordering, rather than less.
>> 
>> It cannot cause problem.
> 
> I agree, but the function could still fail and the caller's logic
> could attempt to call ioreamp or take other action. For example, in
> the case of blue flame, it is better performance-wise to avoid using
> this feature if write combining is not available.

It could, but the less complicated the interfaces the better.
