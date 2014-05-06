From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/24] net, diet: Reduce netdev name hash table for
 CONFIG_BASE_SMALL
Date: Mon, 05 May 2014 23:03:47 -0400 (EDT)
Message-ID: <20140505.230347.627861494715804965.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-2-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:50 -0700

> Small systems typically only have two network devices, so use
> hash shift 2.

Maybe in terms of physical interfaces, but they may also have lots of
software interfaces.

Sorry, this doesn't make any sense, I'm not applying this.
