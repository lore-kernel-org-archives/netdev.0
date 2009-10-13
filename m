From: David Miller <davem@davemloft.net>
Subject: Re: [Patch-next] Fix the size overflow of addrconf_sysctl array
Date: Tue, 13 Oct 2009 03:45:09 -0700 (PDT)
Message-ID: <20091013.034509.130893738.davem@davemloft.net>
References: <4ACEA207.7010208@np.css.fujitsu.com>
	<20091008.224415.205034676.davem@davemloft.net>
	<200910091611.14701.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, jin.dongming@np.css.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, seto.hidetoshi@jp.fujitsu.com,
	netdev@vger.kernel.org
To: cratiu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759432AbZJMKpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:45:13 -0400
In-Reply-To: <200910091611.14701.cratiu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Fri, 9 Oct 2009 16:11:14 +0300

> Shouldn't this be changed too then?
> 
> Or better yet, wouldn't a change that eliminates the need of adding a new 
> option in two separate places be useful?

Yes, it's crummy how things work now, indeed.

> I see the only use for that DEVCONF enum is to dump the settings via netlink.
> Wouldn't a memcpy suffice?

It should be.

I've applied your patch, thanks!
