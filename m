From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 04 Jul 2013 14:32:46 -0700 (PDT)
Message-ID: <20130704.143246.1946946036139459725.davem@davemloft.net>
References: <1372930465.4979.82.camel@edumazet-glaptop>
	<1372931565.7184.32.camel@kazak.uk.xensource.com>
	<1372932730.4979.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, joe.jin@oracle.com, alex@alex.org.uk,
	frank.blaschka@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zheng.x.li@oracle.com,
	xen-devel@lists.xen.org, JBeulich@suse.com,
	stefano.stabellini@eu.citrix.com, konrad.wilk@oracle.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372932730.4979.96.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jul 2013 03:12:10 -0700

> It looks like a typical COW issue to me.

Generically speaking, if we have to mess with page protections this
eliminates the performance gain from bypass/zerocopy/whatever that
these virtualization layers are doing.

But there may be other factors involved which might mitigate that.
