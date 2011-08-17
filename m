From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: boot test failure (net tree)
Date: Tue, 16 Aug 2011 20:04:53 -0700 (PDT)
Message-ID: <20110816.200453.1648804479684623262.davem@davemloft.net>
References: <20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
	<20110816.175657.1688139393736610845.davem@davemloft.net>
	<1313543952.2981.132.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: bhutchings@solarflare.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1313543952.2981.132.camel@deadeye>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 17 Aug 2011 02:19:12 +0100

> If you were to use just "yes", then of course it would.  But since there
> is no explicit default, "yes ''" will deselect them.
> 
> Maybe these guards should have "default y"?

The point is to declutter xconfig and friends, if it defaults to
'y' everything will just always expand.
