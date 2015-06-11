From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: fix handling for drivers not
 supporting IPv4 fib add/del ops
Date: Wed, 10 Jun 2015 23:56:49 -0700 (PDT)
Message-ID: <20150610.235649.1747681763810479422.davem@davemloft.net>
References: <1433981089-51216-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, f.fainelli@gmail.com,
	andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbFKG4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:56:50 -0400
In-Reply-To: <1433981089-51216-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 10 Jun 2015 17:04:49 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> If CONFIG_NET_SWITCHDEV is enabled, but port driver does not implement
> support for IPv4 FIB add/del ops, don't fail route add/del offload
> operations.  Route adds will not be marked as OFFLOAD.  Routes will be
> installed in the kernel FIB, as usual.
> 
> This was report/fixed by Florian when testing DSA driver with net-next on
> devices with L2 offload support but no L3 offload support. What he reported
> was an initial route installed from DHCP client would fail (route not
> installed to kernel FIB).  This was triggering the setting of
> ipv4.fib_offload_disabled, which would disable route offloading after the
> first failure.  So subsequent attempts to install the route would succeed.
> 
> There is follow-on work/discussion to address the handling of route install
> failures, but for now, let's differentiate between no support and failed
> support.
> 
> Reported-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks everyone.
