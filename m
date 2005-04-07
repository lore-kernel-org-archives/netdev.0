From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out
 dev_set_mac_address
Date: Thu, 7 Apr 2005 13:57:56 -0700
Message-ID: <20050407135756.2df03aaa.davem@davemloft.net>
References: <20050407133151.5887c946.davem@davemloft.net>
	<200504072055.j37KtXDf003795@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200504072055.j37KtXDf003795@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Apr 2005 13:55:33 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 	Another alternative would be to change the rtnetlink handler to
> not use a sleepable memory allocation, e.g.,
...
> 	My presumption is that the above would be unacceptable, if for
> no other reason than other notifiers could be attached that also make
> sleepable memory allocations.

You could change it instead to just use gfp_any().

Would that work?  The problematic case occurs from softirq
not hardirq right?
