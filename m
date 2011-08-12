From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 11 Aug 2011 19:51:50 -0700 (PDT)
Message-ID: <20110811.195150.1070520107072994432.davem@davemloft.net>
References: <20110812120248.a23ecc95e9c1111da3a8ef30@canb.auug.org.au>
	<1313116296.2057.30.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1313116296.2057.30.camel@jtkirshe-mobl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Aug 2011 19:31:35 -0700

> I am curious, can you compile the Sun GEM support driver?  and if so,
> does the Spider Net driver compile?

I'm pretty sure you cannot reference object targets outside of
the current directory and expect it to work.

You can only reference things in the current directory (objects,
directories to traverse down into, etc.) as targets

So when there is a common piece of infrastructure shared by
two drivers, you're really going to have to cope with them
at the same time.
