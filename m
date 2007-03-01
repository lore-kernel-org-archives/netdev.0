From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Thu, 01 Mar 2007 14:25:19 -0500
Message-ID: <45E7289F.60406@hp.com>
References: <200703010103.l2113b22030905@death.nxdomain.ibm.com> <20070301164918.GA3199@gospo.rdu.redhat.com> <200703011705.l21H5Q22005750@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:58831 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965520AbXCATZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 14:25:50 -0500
In-Reply-To: <200703011705.l21H5Q22005750@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
>> My only concern is that this code assumes all mcast addresses stored in
>> dev->mc-list list are for ipv4 igmp mcast addresses and nothing was done
>> for ipv6.
>>
>> But this is much better than what we have now, so... 
> 
> 	Agreed, but there's no IPv6 support anywhere in bonding at
> present (for unicast or multicast), so this isn't really a loss.

So forgive my naive question, but what would it take to make IPv6 work? 
  I know DAD fails on a test setup I have, but I haven't dug-into why 
this is (I can guess), and I'd like to see it working.  I'm willing to 
help, even if just to get it limping along.

-Brian
