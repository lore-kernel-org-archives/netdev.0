From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Thu, 03 Feb 2005 20:33:51 +0100
Message-ID: <1107459231.3381.3.camel@localhost.localdomain>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de>
	<20050202223853.GA29237@ti64.telemetry-investments.com>
	<20050202225258.GA15563@suse.de> <20050203111939.GI31570@suse.de>
	<20050203104822.05be3281.davem@davemloft.net>
	<20050203185928.GA22832@suse.de>
	<20050203110049.6b2d9c64.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	brugolsky@telemetry-investments.com, Olaf Hering <olh@suse.de>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050203110049.6b2d9c64.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Op do, 03-02-2005 te 11:00 -0800, schreef David S. Miller:
> On Thu, 3 Feb 2005 19:59:28 +0100
> Olaf Hering <olh@suse.de> wrote:
> 
> >  On Thu, Feb 03, David S. Miller wrote:
> > 
> > > The rule itself is replicated per-cpu as well to keep L2 cache
> > > accesses local per cpu on SMP systems.
> > 
> > Andy made this change, which helped on a dual box.
> 
> It might not help for Olaf's 128 cpu box though :-)
> 
> I think reconsider the idea of replicating the rule itself per-cpu.
> Also, this thread should have begun with netfilter-devel at least on
> the CC:, added.

Note that ebtables only has per-cpu counters.
I wonder what limits are seen on such systems for ebtables.

cheers,
Bart
