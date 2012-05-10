From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Wed, 09 May 2012 23:54:20 -0700
Message-ID: <1336632860.22495.6.camel@joe2Laptop>
References: <cover.1336538937.git.joe@perches.com>
	 <20120509.212110.437114897180819434.davem@davemloft.net>
	 (sfid-20120510_032248_153593_581BC374) <1336632528.4334.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336632528.4334.1.camel@jlt3.sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-10 at 08:48 +0200, Johannes Berg wrote:
> On Wed, 2012-05-09 at 21:21 -0400, David Miller wrote:
> 
> > That case you didn't convert in mac80211 is probably the
> > bug Johannes was talking about which started this whole
> > discussion.
> 
> The bug case that started it all is in net/wireless/scan.c and Emmanuel
> has since changed it back to memcmp(). Not sure if that's the one you
> were referring to or not :-)

That's the one that I left alone.

Post patch:
$ git grep -n -w compare_ether_addr net
net/batman-adv/main.h:198: * note: can't use compare_ether_addr() as it requires aligned memory
net/wireless/scan.c:381:        return compare_ether_addr(a->bssid, b->bssid);


