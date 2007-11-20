From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] IPVS: Fix sysctl warnings about missing strategy
 in schedulers
Date: Mon, 19 Nov 2007 21:50:40 -0800 (PST)
Message-ID: <20071119.215040.123959687.davem@davemloft.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
	<20071114180823.092364787@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	wensong@linux-vs.org, ja@ssi.bg, borntraeger@de.ibm.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752527AbXKTFul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:50:41 -0500
In-Reply-To: <20071114180823.092364787@natsuko.shinjuku.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 10:06:17 -0800

> sysctl table check failed: /net/ipv4/vs/lblc_expiration .3.5.21.19 Missing strategy
> [...]
> sysctl table check failed: /net/ipv4/vs/lblcr_expiration .3.5.21.20 Missing strategy
> 
> Switch these entried over to use CTL_UNNUMBERED as clearly
> the sys_syscal portion wasn't working.
> 
> This is along the same lines as Christian Borntraeger's patch that fixes
> up entries with no stratergy in net/ipv4/ipvs/ip_vs_ctl.c
> 
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Wensong Zhang <wensong@linux-vs.org>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Patch applied, thanks Simon.
