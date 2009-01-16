From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: include ipv6.h (fixes build failure)
Date: Fri, 16 Jan 2009 11:04:52 -0800 (PST)
Message-ID: <20090116.110452.77631610.davem@davemloft.net>
References: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
	<1232130484-25188-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756195AbZAPTEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:04:51 -0500
In-Reply-To: <1232130484-25188-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Fri, 16 Jan 2009 10:28:04 -0800

> Fixes a build error in absence of CONFIG_IPV6:
> 
> drivers/net/netxen/netxen_nic_main.c:1189: error: implicit declaration of function 'ipv6_hdr'
> drivers/net/netxen/netxen_nic_main.c:1189: error: invalid type argument of '->'
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Gee, thanks for not even mentioning Ingo having reported this problem
in your commit message. :-((

I've fixed this when committing.

You didn't even CC: him on this patch posting, what gives?

