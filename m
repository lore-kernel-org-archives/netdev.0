From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: offical fix for CVE-2009-4537 (overlength frame
 DMAs)
Date: Mon, 29 Mar 2010 15:09:24 -0700 (PDT)
Message-ID: <20100329.150924.144366212.davem@davemloft.net>
References: <20100329160356.GC22733@hmsreliant.think-freely.org>
	<1269900105.8653.389.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, michael.s.gilbert@gmail.com,
	davem@davemeloft.net, romieu@fr.zoreil.com, eric.dumazet@gmail.com
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269900105.8653.389.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 29 Mar 2010 23:01:45 +0100

> It also sucks that the secure but low-performance behaviour is enabled
> for all variants, while AIUI only some suffer from the bug.  I realise
> you probably don't have access to every variant (and neither does
> Francois) but perhaps you could come up with a test case that could be
> used to start whitelisting common variants that don't have the bug?

As far as we know all chip variants seem to have the problem.

Furthermore, this issue has been known about and investigated for
about 3 months.  In that time no better options for handling this
issue reliably have been discovered and implemented.

Feel free to code up (and test) something better yourself if you don't
like the fix as it exists currently. :-)
