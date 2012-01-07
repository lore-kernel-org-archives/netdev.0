From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] pktgen: set correct max and min in pktgen_setup_inject()
Date: Sat, 07 Jan 2012 12:25:47 -0800 (PST)
Message-ID: <20120107.122547.2205195083782290771.davem@davemloft.net>
References: <20120106131346.GA2491@elgon.mountain>
	<20120106092912.000015cd@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab2AGUZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 15:25:53 -0500
In-Reply-To: <20120106092912.000015cd@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 6 Jan 2012 09:29:12 -0800

> On Fri, 6 Jan 2012 05:13:47 -0800
> Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
>> In 882716604ec "pktgen: fix multiple queue warning" we added special
>> logic to handle the case where ntxq is zero.  It's not clear to me that
>> ntxq can actually be zero.  But if it were then we would set
>> ->queue_map_min and ->queue_map_max to USHRT_MAX when probably we want
>> to set them to zero?
> 
> seems fine to me, esp since -1 seems like a bad value there.

Looks good to me too, applied, thanks everyone.
