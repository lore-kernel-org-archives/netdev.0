From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for January 31 (ip_vs)
Date: Mon, 31 Jan 2011 15:00:31 -0800 (PST)
Message-ID: <20110131.150031.70194609.davem@davemloft.net>
References: <20110131101829.b842da44.randy.dunlap@oracle.com>
	<20110131211846.GH2389@verge.net.au>
	<20110131225727.GA23992@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: horms@verge.net.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110131225727.GA23992@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Tue, 1 Feb 2011 09:57:28 +1100

> On Tue, Feb 01, 2011 at 08:18:47AM +1100, Simon Horman wrote:
>> On Mon, Jan 31, 2011 at 10:18:29AM -0800, Randy Dunlap wrote:
>> > On Mon, 31 Jan 2011 17:41:13 +1100 Stephen Rothwell wrote:
>> > 
>> > > Hi all,
>> > > 
>> > > Changes since 20110121:
>> > > 
>> > > The net tree lost its build failure.
>> > 
>> > 
>> > When CONFIG_SYSCTL is not enabled:
>> > 
>> > net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
>> > ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
>> > ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
>> 
>> Thanks, I'm looking into it.
> 
> On a related note, does IPVS need to handle the case
> where CONFIG_PROC_FS is not enabled?

Yes.
