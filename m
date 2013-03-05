From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Tue, 05 Mar 2013 14:55:24 -0500 (EST)
Message-ID: <20130305.145524.1486936679665458305.davem@davemloft.net>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
	<1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.jf.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 5 Mar 2013 16:43:01 +0000

> In general it appears to require a run-time check.  You might need to
> augment <asm/timex.h>.

On the other hand, unlike get_cycles, sched_clock() is always available.
