From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Wed, 29 Apr 2009 09:45:10 +0400
Message-ID: <20090429054510.GA8267@night.netis.ru>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:52753 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776AbZD2FpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 01:45:17 -0400
Content-Disposition: inline
In-Reply-To: <49F76BF6.4040709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2009 at 10:49:58PM +0200, Jarek Poplawski wrote:
> Do you mean if you wait a bit longer (until the first one is really removed)

The problem is that it is never removed. I waited for at least 30 minutes.

> before running another one, it doesn't s(t)uck? Is there a change e.g. wrt.
> 2.6.28?

I mean, 'vconfig rem' on another interface stucks if the previous vconfig
has not finished, and it never finishes. So I cannot check if other vlan
interfaces have the same 'refcnt' problem. So far I tried 'vconfig rem' on
two vlan interfaces and I have a dozen.

Again, the problem only happens after I notice surprisingly high LA (30
instead of 2-6) and interactive slowness. When it happens, I check network
usage, disk usage, cpu usage, mem usage - they are normal or even lower than
usual.

The server is running transparent squid and named. The last kernel version
was 2.6.27.21 and it did not have this problem.

-- 
   Alexander.
