From: "David S. Miller" <davem@davemloft.net>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Thu, 3 Feb 2005 10:48:22 -0800
Message-ID: <20050203104822.05be3281.davem@davemloft.net>
References: <20050202133851.GA9680@suse.de>
	<20050202222516.GA15440@suse.de>
	<20050202223853.GA29237@ti64.telemetry-investments.com>
	<20050202225258.GA15563@suse.de>
	<20050203111939.GI31570@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, brugolsky@telemetry-investments.com, netdev@oss.sgi.com
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050203111939.GI31570@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Feb 2005 12:19:39 +0100
Olaf Kirch <okir@suse.de> wrote:

> At 3445 rules, tmp.size is 524272 (why does it want that much memory? I
> would expect the only data that's per-CPU is the packet and byte
> counters).

The rule itself is replicated per-cpu as well to keep L2 cache
accesses local per cpu on SMP systems.
