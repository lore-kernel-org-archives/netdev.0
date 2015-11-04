From: David Miller <davem@davemloft.net>
Subject: Re: [kbuild-all] [PATCH] mpls: fix semicolon.cocci warnings
Date: Wed, 04 Nov 2015 09:57:40 -0500 (EST)
Message-ID: <20151104.095740.1875720480943254459.davem@davemloft.net>
References: <20151103.111736.1351482614470057979.davem@davemloft.net>
	<20151104020151.GA25902@wfg-t540p.sh.intel.com>
	<alpine.DEB.2.02.1511040746350.2068@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	rshearma@brocade.com, kbuild-all@01.org, ebiederm@xmission.com
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318AbbKDO5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 09:57:45 -0500
In-Reply-To: <alpine.DEB.2.02.1511040746350.2068@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Wed, 4 Nov 2015 07:50:05 +0100 (CET)

> The whole idea of a macro that declares variables some of which are then 
> used in the code under the macro also seems quite unpleasant.  Other 
> iterators don't do this, and so they don't need the end marker.

I'm open minded about cleaning these iterators up.
