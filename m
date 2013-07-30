From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Tue, 30 Jul 2013 00:49:23 -0700 (PDT)
Message-ID: <20130730.004923.1092822113714066844.davem@davemloft.net>
References: <1374602291.3387.17.camel@joe-AO722>
	<20130730.001001.618776305200728182.davem@davemloft.net>
	<20130730173800.1825a1452694f40370699413@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730173800.1825a1452694f40370699413@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 30 Jul 2013 17:38:00 +1000

> I must admit I prefer the other way (i.e. with the explicit extern).  If
> nothing else it makes it consistent with variable declarations in header
> files (which need the extern) and "static inlines" ...
> 
> Making these churn changes also will almost certainly cause unnecessary
> conflicts :-(

Regardless of preferences, the whole tree is a mix, and we should choose
one way or the other consistently.

It seems like new code in other major subsystems are using the
no-extern scheme, and I'm more than happy to follow suit.
