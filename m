From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Thu, 10 May 2012 08:56:55 +0200
Message-ID: <1336633015.4334.2.camel@jlt3.sipsolutions.net>
References: <cover.1336538937.git.joe@perches.com>
	<20120509.212110.437114897180819434.davem@davemloft.net>
	(sfid-20120510_032248_153593_581BC374)
	<1336632528.4334.1.camel@jlt3.sipsolutions.net>
	<1336632860.22495.6.camel@joe2Laptop>
	(sfid-20120510_085441_236331_94537C40)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1336632860.22495.6.camel@joe2Laptop>
	(sfid-20120510_085441_236331_94537C40)
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-09 at 23:54 -0700, Joe Perches wrote:
> On Thu, 2012-05-10 at 08:48 +0200, Johannes Berg wrote:
> > On Wed, 2012-05-09 at 21:21 -0400, David Miller wrote:
> > 
> > > That case you didn't convert in mac80211 is probably the
> > > bug Johannes was talking about which started this whole
> > > discussion.
> > 
> > The bug case that started it all is in net/wireless/scan.c and Emmanuel
> > has since changed it back to memcmp(). Not sure if that's the one you
> > were referring to or not :-)
> 
> That's the one that I left alone.
> 
> Post patch:
> $ git grep -n -w compare_ether_addr net
> net/batman-adv/main.h:198: * note: can't use compare_ether_addr() as it requires aligned memory
> net/wireless/scan.c:381:        return compare_ether_addr(a->bssid, b->bssid);

Ok, great, then that means the fix from Emmanuel won't conflict when it
gets in.

johannes
