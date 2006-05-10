From: "David S. Miller" <davem@davemloft.net>
Subject: Re: address pingable with interface down
Date: Wed, 10 May 2006 13:00:12 -0700 (PDT)
Message-ID: <20060510.130012.128043400.davem@davemloft.net>
References: <20060510194818.GB4460@junkers.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33178
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750813AbWEJUAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:00:47 -0400
To: jadevree@mtu.edu
In-Reply-To: <20060510194818.GB4460@junkers.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon DeVree <jadevree@mtu.edu>
Date: Wed, 10 May 2006 15:48:18 -0400

> I've noticed in the past that the address owned by an interface is
> still pingable after that interface is brought down.

People bring this up all the time and this behavior is
intentional.

Linux uses a "host based" addressing model, IP addresses are owned by
the host, not individual interfaces. So as long as the IP address is
configured to some interface, we will accept packets destinated to
that IP address as our's.

This is becoming a serious FAQ and very tiresome to explain over and
over again.
