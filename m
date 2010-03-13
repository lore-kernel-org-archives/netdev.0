From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix PHY polling system blocking
Date: Sat, 13 Mar 2010 12:12:48 -0800 (PST)
Message-ID: <20100313.121248.76758764.davem@davemloft.net>
References: <1268484790.6339.37.camel@wall-e>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268484790.6339.37.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>
Date: Sat, 13 Mar 2010 13:53:10 +0100

> For PHY chips without interrupts, the status of the ethernet will be
> polled every 2 sec. The poll function will read some register of the MII
> PHY. The time between the sending the MII_READ_COMMAND and receiving the
> result could be very long (>100us).

I'm not apply this, as I described in my previous email.

If it's expensive to detect link configuration changes that
doesn't mean you just turn it off.
