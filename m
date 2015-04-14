From: Honggang LI <honli@redhat.com>
Subject: Re: [PATCH linux-next 3/4] macvlan: fix possible NULL pointer
 dereference in macvlan_dev_get_iflink
Date: Tue, 14 Apr 2015 23:46:49 +0800
Message-ID: <20150414154649.GC21856@honli.nay.redhat.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
 <1429024817-21561-4-git-send-email-honli@redhat.com>
 <20150414152626.GJ7874@acer.localdomain>
 <552D33B0.6040808@6wind.com>
 <20150414153757.GA10861@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Patrick McHardy <kaber@trash.net>, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, alex.estrin@intel.com, dledford@redhat.com,
	edumazet@google.com, erezsh@mellanox.com, maheshb@google.com,
	jbenc@redhat.com, ebiederm@xmission.com,
	elfring@users.sourceforge.net, f.fainelli@gmail.com,
	linux@roeck-us.net, sfeldma@gmail.com, alexander.h.duyck@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754102AbbDNPrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 11:47:16 -0400
Content-Disposition: inline
In-Reply-To: <20150414153757.GA10861@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 05:37:57PM +0200, Andrew Lunn wrote:
> > >
> > And I suspect that it is the same for ipvlan and dsa.
> 
> I agree about DSA. I don't see any way this could happen.
> 
>   Andrew

I only keep the ipoib patch and drop the rest patches.

thanks
