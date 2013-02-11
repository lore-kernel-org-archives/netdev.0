From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top of LRO
Date: Sun, 10 Feb 2013 20:15:28 -0500 (EST)
Message-ID: <20130210.201528.104811532648035805.davem@davemloft.net>
References: <20130207.131420.1211188723341167971.davem@davemloft.net>
	<20130207213315.GB5064@redhat.com>
	<1360276295.3605.44.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eilong@broadcom.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com,
	john.r.fastabend@intel.com, jacob.e.keller@intel.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360276295.3605.44.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 7 Feb 2013 22:31:35 +0000

> On Thu, 2013-02-07 at 23:33 +0200, Michael S. Tsirkin wrote:
>> We might want to add code to forward LRO status from macvlan
>> (not macvtap) back to the lowerdev, so that setting up forwarding
>> from macvlan disables LRO on the lowerdev, but that seems like another
>> issue.
> 
> I think it's the same issue!

I do too, can someome please work to resolve this properly?

Thanks.
