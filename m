From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 06 Mar 2007 14:55:28 -0500
Message-ID: <45EDC730.40007@hp.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com> <200703011705.l21H5Q22005750@death.nxdomain.ibm.com> <45E7289F.60406@hp.com> <20070301194305.GB3199@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:44901 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbXCFUTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 15:19:25 -0500
In-Reply-To: <20070301194305.GB3199@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> If we are easily able to differentiate between the multicast addresses
> in the mc_list as to which are for ipv4 and which are for ipv6 then it
> would be easy to call-out to something in the ipv6 mcast code when
> needed instead of always calling out to ipv4 code.

I've been unable to figure out exactly what you're referring to in the 
code (bond_main.c), it seems to failover all multicast addresses, 
regardless of what address family they are.  I might have missed 
something in 4K lines of code though?

-Brian
