From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUGFIX 0/6] pkt_sched: fix little service anomalies and
 possible crashes of qfq+
Date: Tue, 05 Mar 2013 23:50:06 -0500 (EST)
Message-ID: <20130305.235006.1904081547083683406.davem@davemloft.net>
References: <20130226.173700.882998504986475149.davem@davemloft.net>
	<1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fchecconi@gmail.com,
	rizzo@iet.unipi.it
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo valente <paolo.valente@unimore.it>
Date: Tue,  5 Mar 2013 19:04:56 +0100

> Split, and inserted a detailed description of both the problem and the fix
> in each patch.

Series applied, thanks.

Although two topics for possibly resolving later:

1) That 1ULL bit mask fix is quite expensive on 32-bit, it would
   probably be cheaper to test for that case using a helper function
   that nops out on 64-bit.  Although this is not so important.

2) That static inline forward declaration is ugly, better to remove
   the inline tag (let the compiler handle it) or move the function
   above all the call sites.
