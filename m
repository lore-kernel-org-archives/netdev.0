From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26][IPV6]: Fix potential net leak and oops in
 ipv6 routing code.
Date: Wed, 26 Mar 2008 16:50:02 -0700 (PDT)
Message-ID: <20080326.165002.128017657.davem@davemloft.net>
References: <47EA7203.6070704@openvz.org>
	<47EA72E1.804@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752899AbYCZXuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 19:50:02 -0400
In-Reply-To: <47EA72E1.804@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 26 Mar 2008 16:59:29 +0100

> Pavel Emelyanov wrote:
> > The commits f3db4851 ([NETNS][IPV6] ip6_fib - fib6_clean_all handle several 
> > network namespaces) and 69ddb805 ([NETNS][IPV6] route6 - Make proc entry 
> > /proc/net/rt6_stats per namespace) made some proc files per net.
> > 
> > Both of them introduced potential OOPS - get_proc_net can return NULL, but
> > this check is lost - and a struct net leak - in case single_open() fails the
> > previously got net is not put.
> > 
> > Kill all these bugs with one patch.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
 ...
> Good catch. Thanks.
> 
> Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks everyone!
