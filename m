From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Tue, 05 Mar 2013 14:57:19 -0500 (EST)
Message-ID: <20130305.145719.1469904264539814585.davem@davemloft.net>
References: <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
	<1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
	<5136282E.9080307@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eliezer.tamir@linux.jf.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net,
	willemb@google.com, andi@firstfloor.org, hpa@zytor.com,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5136282E.9080307@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Tue, 05 Mar 2013 19:15:26 +0200

> We are not very sensitive to this setting, anything on the order of
> your half round time trip plus a few standard deviations works well.
> We are busy waiting, so setting a higher value does not change the
> results much.

This makes the argument for using sched_clock() even stronger.
