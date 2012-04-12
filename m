From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 17:10:04 -0700
Message-ID: <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
References: <alpine.SOC.1.00.1203281134090.13691@math.ut.ee>
	<20120328.174559.650861844028495880.davem@davemloft.net>
	<alpine.SOC.1.00.1204111807420.26884@math.ut.ee>
	<20120411230837.GC2473@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120411230837.GC2473@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Apr 2012 16:08:37 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> Hmmm...  What CPU family is this running on?  From the look of the
> stack, it is sneaking out of idle into softirq without telling RCU.
> This would cause RCU to complain bitterly about being invoked from
> the idle loop -- and RCU ignores CPUs in the idle loop.
> 
> 							Thanx, Paul

Sun4... Ping David.
