From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] skb fragment API: convert non-network drivers
Date: Fri, 26 Aug 2011 12:39:05 -0400 (EDT)
Message-ID: <20110826.123905.2087707552692035948.davem@davemloft.net>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	devel@open-fcoe.org
To: Ian.Campbell@citrix.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 25 Aug 2011 09:28:01 +0100

> The following series converts some non-network drivers to the SKB pages
> fragment API introduced in 131ea6675c76. Included are ATM, Infiniband,
> and FibreChannel. I also included the broadcom network drivers since I
> was touching the related FC driver.
> 
> This is part of my series to enable visibility into SKB paged fragment's
> lifecycles, [0] contains some more background and rationale but
> basically the completed series will allow entities which inject pages
> into the networking stack to receive a notification when the stack has
> really finished with those pages (i.e. including retransmissions,
> clones, pull-ups etc) and not just when the original skb is finished
> with, which is beneficial to many subsystems which wish to inject pages
> into the network stack without giving up full ownership of those page's
> lifecycle. It implements something broadly along the lines of what was
> described in [1].

All applied, thanks Ian.
