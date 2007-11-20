From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] IPVS: Fix sysctl warnings about missing strategy
Date: Mon, 19 Nov 2007 21:49:47 -0800 (PST)
Message-ID: <20071119.214947.104888430.davem@davemloft.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
	<20071114180821.777103318@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	wensong@linux-vs.org, ja@ssi.bg, borntraeger@de.ibm.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37061
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756425AbXKTFts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:49:48 -0500
In-Reply-To: <20071114180821.777103318@natsuko.shinjuku.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 10:06:16 -0800

> From: Christian Borntraeger <borntraeger@de.ibm.com>
> 
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
> CC: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Acked-by: Simon Horman <horms@verge.net.au>

Patch applied.
