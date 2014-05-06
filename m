From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/24] net, diet: Support simpler routing table
Date: Mon, 05 May 2014 23:02:59 -0400 (EDT)
Message-ID: <20140505.230259.1803147080660592366.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-23-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com,
	robert.olsson@its.uu.se
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-23-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:11 -0700

> Add an optional fib_list that uses a simple list to store routes.
> This is suitable for single homed client system which typically
> have only a handful of routes.

Sorry I'm not applying this.

We had two routing table implementations for some time and it sucked,
it meant two code paths and two places for bugs to hide.

I want only one data structure which does the job well, and we have
that now.
