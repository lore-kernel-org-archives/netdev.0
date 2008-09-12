From: David Miller <davem@davemloft.net>
Subject: Re: [stable] regression in iptables: recent filter
Date: Thu, 11 Sep 2008 20:04:38 -0700 (PDT)
Message-ID: <20080911.200438.01253897.davem@davemloft.net>
References: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com>
	<20080911200133.48be32fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gcoady.lk@gmail.com, grant_lkml@dodo.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080911200133.48be32fa.akpm@linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 11 Sep 2008 20:01:33 -0700

> On Fri, 12 Sep 2008 11:53:35 +1000 Grant Coady <grant_lkml@dodo.com.au> wrote:
> 
> > Hi there,
> > 
> > Last known good kernel: 2.6.24.7
> > 
> > # iptables -N calmrate
> > # iptables -A calmrate -p tcp -m state --state NEW \
> > 	-m recent --name listrate --update --rttl \
> > 	--seconds 60 --hitcount 60 -j DROP
> > iptables: Unknown error 4294967295
> > 
> > Fails for 2.6.25.17 and 2.6.26.5
> > 
> > dmesg + config: http://bugsplatter.id.au/kernel/boxen/deltree/
> > 
> 
> (cc netdev)

(cc netfilter-devel)

For those playing at home, 4294967295 is 32-bit -1.
