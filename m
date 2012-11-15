From: David Miller <davem@davemloft.net>
Subject: Re: question about RT_TABLE_MAX
Date: Wed, 14 Nov 2012 20:28:02 -0500 (EST)
Message-ID: <20121114.202802.23715201166879903.davem@davemloft.net>
References: <20121112145135.GA32199@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992520Ab2KOB2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 20:28:05 -0500
In-Reply-To: <20121112145135.GA32199@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 12 Nov 2012 17:51:35 +0300

> RT_TABLE_MAX is 0xFFFFFFFF.  It's always compared against an unsigned
> int so the checks against it don't test anything.

It used to be 256, that's why the spurious tests are there, they
just need to be cleaned up.

This change happened in commit:

commit b801f54917b7c6e8540f877ee562cd0725e62ebd
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Aug 10 23:12:34 2006 -0700

    [NET]: Increate RT_TABLE_MAX to 2^32

    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>
