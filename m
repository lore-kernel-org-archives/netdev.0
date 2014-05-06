From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 22:06:44 +0200
Message-ID: <20140506200644.GC5619@two.firstfloor.org>
References: <20140506164546.GB20536@cloud>
 <20140506.131752.740569380523989782.davem@davemloft.net>
 <20140506172106.GB20776@cloud>
 <20140506.132501.331724703594119414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, eric.dumazet@gmail.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506.132501.331724703594119414.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You see, that's the point I'm trying to make, once it's upstream
> then it's my problem.

FWIW I don't think any of the changes I proposed would be likely
to add lots of new bugs. Nothing was really adding any significant new logic,
just doing less (modulo perhaps fib_list) Was that your main concern?

I realize the many config options are something that could
be consolidated to ease compile time testing.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
