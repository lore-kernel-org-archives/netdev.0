From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly
Date: Fri, 20 Jun 2008 22:19:06 -0700 (PDT)
Message-ID: <20080620.221906.98088315.davem@davemloft.net>
References: <20080620115603.5c494cab@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751144AbYFUFTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 01:19:07 -0400
In-Reply-To: <20080620115603.5c494cab@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Jun 2008 11:56:03 -0700

> I found another case where we are sending information to userspace
> in the wrong HZ scale.  This should have been fixed back in 2.5 :-(
> 
> This means an ABI change but as it stands there is no way for an application
> like ss to get the right value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Please fix these warnings and resubmit:

net/ipv4/tcp_ipv4.c: In function 'get_tcp4_sock':
net/ipv4/tcp_ipv4.c:2311: warning: format '%u' expects type 'unsigned int', but argument 19 has type 'clock_t'
net/ipv4/tcp_ipv4.c:2311: warning: format '%u' expects type 'unsigned int', but argument 20 has type 'clock_t'
net/ipv6/tcp_ipv6.c: In function 'get_tcp6_sock':
net/ipv6/tcp_ipv6.c:2059: warning: format '%u' expects type 'unsigned int', but argument 25 has type 'clock_t'
net/ipv6/tcp_ipv6.c:2059: warning: format '%u' expects type 'unsigned int', but argument 26 has type 'clock_t'

Thanks!
