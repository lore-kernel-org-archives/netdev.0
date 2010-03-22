From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 22 Mar 2010 17:35:07 -0500
Message-ID: <1269297307.3552.23.camel@calx>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
	 <20100322082112.4967.5504.sendpatchset@localhost.localdomain>
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
In-Reply-To: <20100322082112.4967.5504.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-03-22 at 04:17 -0400, Amerigo Wang wrote:
> Based on the previous patch, make bridge support netpoll by:
> 
> 1) implement the 4 methods to support netpoll for bridge;
> 
> 2) modify netpoll during forwarding packets in bridge;
> 
> 3) disable netpoll support of bridge when a netpoll-unabled device
>    is added to bridge;

Not sure if this is the right thing to do. Shouldn't we simply enable
polling on all devices that support it and warn about the others (aka
best effort)?

-- 
http://selenic.com : development and support for Mercurial and Linux
