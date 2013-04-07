From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/8] r8169: Remove firmware code
Date: Sun, 07 Apr 2013 16:45:07 -0400 (EDT)
Message-ID: <20130407.164507.795222306786228518.davem@davemloft.net>
References: <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
	<20130404.174717.2232220782916755499.davem@davemloft.net>
	<20130404234229.GA13629@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130404234229.GA13629@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 5 Apr 2013 01:42:29 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> If so, should I just apply this series as-is ?
> 
> Yes.
> 
> - the series is imho -stable unfriendly: whoever wants to figure what
>   should be fed into a -stable branch will have a hard time. :o/
> - the driver could had been more careful about firmware version/magic
>   checks and firmware opcodes recycling. It's a bit late. It won't
>   necessarily hurt.
> - there is a whole release cycle ahead to find problems - if any - due
>   to the hw_start flow change. It seems sane.
> - the relative amount of binary like cruft is going down.
> 
> I am not overflowed with enthusiasm but the gain should exceed the pain.

All applied to net-next, thanks!
