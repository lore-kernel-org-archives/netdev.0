From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 1/8] r8169: Remove firmware code
Date: Fri, 5 Apr 2013 01:42:29 +0200
Message-ID: <20130404234229.GA13629@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
 <20130404.174717.2232220782916755499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130404.174717.2232220782916755499.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
[...]
> I see there is still some discussion about dependencies between
> patch #5 and #6, is that resolved?

Yes.

> If so, should I just apply this series as-is ?

Yes.

- the series is imho -stable unfriendly: whoever wants to figure what
  should be fed into a -stable branch will have a hard time. :o/
- the driver could had been more careful about firmware version/magic
  checks and firmware opcodes recycling. It's a bit late. It won't
  necessarily hurt.
- there is a whole release cycle ahead to find problems - if any - due
  to the hw_start flow change. It seems sane.
- the relative amount of binary like cruft is going down.

I am not overflowed with enthusiasm but the gain should exceed the pain.

-- 
Ueimor
