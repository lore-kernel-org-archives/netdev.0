From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 17:12:48 -0700 (PDT)
Message-ID: <20150825.171248.291365392844717283.davem@davemloft.net>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHZAMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:12:49 -0400
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 25 Aug 2015 15:50:10 -0700

> This patch series implements a L2 only interface concept which
> basically denies any kind of IP address configuration on these
> interfaces, but still allows them to be used as configuration
> end-points to keep using ethtool and friends.
> 
> A cleaner approach might be to finally come up with the concept of
> net_port which a net_device would be a superset of, but this still
> raises tons of questions as to whether we should be modifying
> userland tools to be able to configure/query these
> interfaces. During all the switch talks/discussions last year, it
> seemed to me like th L2-only interface is closest we have to a
> "network port".
> 
> Comments, flames, flying tomatoes welcome!

Interesting, indeed.

Do you plan to extend this to defining a more minimal network device
sub-type as well?

Then we can pass "net_device_common" or whatever around as a common
base type of actual net device "implementations".

Or is you main goal just getting the L2-only semantic?
