From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Tue, 13 Nov 2007 02:45:00 -0800 (PST)
Message-ID: <20071113.024500.155458534.davem@davemloft.net>
References: <200711131129.58868.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: borntraeger@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbXKMKpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 05:45:02 -0500
In-Reply-To: <200711131129.58868.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 13 Nov 2007 11:29:58 +0100

> Running the latest git code I get the following messages during boot:
> sysctl table check failed: /net/ipv4/vs/drop_entry .3.5.21.4 Missing strategy
> [...]		  
> sysctl table check failed: /net/ipv4/vs/drop_packet .3.5.21.5 Missing strategy
> [...]
> sysctl table check failed: /net/ipv4/vs/secure_tcp .3.5.21.6 Missing strategy
> [...]
> sysctl table check failed: /net/ipv4/vs/sync_threshold .3.5.21.24 Missing strategy
> 
> I removed the binary sysctl handler for those messages and also removed
> the definitions in ip_vs.h. The alternative would be to implement a 
> proper strategy handler, but syscall sysctl is deprecated.
> 
> There are other sysctl definitions that are commented out or work with 
> the default sysctl_data strategy. I did not touch these. 
> 
> Eric, IPVS team, are you ok with that change?
> 
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Wensong Zhang <wensong@linux-vs.org>
> CC: Simon Horman <horms@verge.net.au>
> CC: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

Simon planned to make a similar change to dice all of this
stuff up.  He is travelling currently, and I think it's
reasonable to give him some time to get to it.
