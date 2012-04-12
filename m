From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 20:18:54 -0400 (EDT)
Message-ID: <20120411.201854.1070083308359208025.davem@davemloft.net>
References: <alpine.SOC.1.00.1204111807420.26884@math.ut.ee>
	<20120411230837.GC2473@linux.vnet.ibm.com>
	<20120411171004.016ddd95@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mroos@linux.ee,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 11 Apr 2012 17:10:04 -0700

> On Wed, 11 Apr 2012 16:08:37 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
>> Hmmm...  What CPU family is this running on?  From the look of the
>> stack, it is sneaking out of idle into softirq without telling RCU.
>> This would cause RCU to complain bitterly about being invoked from
>> the idle loop -- and RCU ignores CPUs in the idle loop.
>> 
>> 							Thanx, Paul
> 
> Sun4... Ping David.

So is there anything specific I need to do in the sparc64
idle loop?
