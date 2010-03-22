From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC Patch 3/3] bonding: make bonding support netpoll
Date: Mon, 22 Mar 2010 17:38:05 -0500
Message-ID: <1269297485.3552.26.camel@calx>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
	 <20100322082123.4967.77433.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322082123.4967.77433.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-03-22 at 04:17 -0400, Amerigo Wang wrote:
> Based on Andy's work, but I modify a lot.
> 
> Similar to the patch for bridge, this patch does:
> 
> 1) implement the 4 methods to support netpoll for bonding;
> 
> 2) modify netpoll during forwarding packets in bonding;
> 
> 3) disable netpoll support of bridge when a netpoll-unabled device
>    is added to bonding;
> 
> 4) enable netpoll support when all underlying devices support netpoll.

Again, not sure if this is the right policy. Seems to me that on a
bonding device we should simply pick an interface to send netpoll
messages on, without reference to balancing, etc. Thus, if any of the
bonded devices supports polling, it should work.

Hopefully someone more familiar with the goals and philosophy of the
bonding code can comment further.

-- 
http://selenic.com : development and support for Mercurial and Linux
