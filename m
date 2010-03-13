From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix PHY polling system blocking
Date: Sat, 13 Mar 2010 12:10:44 -0800 (PST)
Message-ID: <20100313.121044.180110930.davem@davemloft.net>
References: <1267894258.18869.2.camel@wall-e>
	<20100312144248.ade8b700.akpm@linux-foundation.org>
	<1268481242.4885.70.camel@wall-e>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268481242.4885.70.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>
Date: Sat, 13 Mar 2010 12:54:02 +0100

> There is not real drawback, only the detection of a connection type
> change without unplugging the cable will not work. But this is more an
> esoteric use case.

I don't think it's so esoteric.

We should definitely notice all link state and capability changes.

If proper functionality cannot be done without an expensive operation,
it doesn't mean we take away the proper functionality.

I really don't agree with these changes, sorry.
