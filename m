From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Create temporary address if none
 exists.
Date: Thu, 30 Sep 2010 17:42:54 -0700 (PDT)
Message-ID: <20100930.174254.184831800.davem@davemloft.net>
References: <20100927170430.GA7106@adams.ccsl.carleton.ca>
	<20100928.222510.71109554.davem@davemloft.net>
	<4CA35084.8010503@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gwurster@scs.carleton.ca, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: brian.haley@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA35084.8010503@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 29 Sep 2010 10:43:16 -0400

> From what I have found, this is fixing the case where we've changed
> use_tempaddr to 1 on an interface that already has a "stable" IPv6
> prefix.  In that case you'll never add a temporary address:

We should have enough information to instantiate the temporary address
when the syscal value is enabled.  So I would prefer if we fixed it
that way.
