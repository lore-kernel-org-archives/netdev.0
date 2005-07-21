From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Thu, 21 Jul 2005 13:12:50 -0700 (PDT)
Message-ID: <20050721.131250.55509013.davem@davemloft.net>
References: <20050718.203145.105430424.davem@davemloft.net>
	<20050720132305.GA4077@rama> <1121970035.5904.6.camel@notepaq>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: marcel@holtmann.org
In-Reply-To: <1121970035.5904.6.camel@notepaq>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 21 Jul 2005 20:20:35 +0200

> However after a look trough the Bluetooth core it should be quite
> easy too move the pkt_type into the control buffer. We already use
> it for a direction bit. The nasty thing is that I have to modify all
> the drivers. So when you finally decided to shrink the pkt_type, I
> think that I can come up with a patch for it quiet quickly.

We are trimming SKB madly right now, so if you could work on
the bluetooth patch so we can trim the pkt_type size ASAP
that would be much appreciated.  You can send diffs against
my net-2.6.14 tree at:

   rsync://rsync.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.14.git

Thanks.
