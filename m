From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Fri, 22 Jul 2005 15:54:11 -0700 (PDT)
Message-ID: <20050722.155411.32722751.davem@davemloft.net>
References: <1121989791.5892.8.camel@notepaq>
	<20050721.165207.35016196.davem@davemloft.net>
	<1121991994.5892.15.camel@notepaq>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: marcel@holtmann.org
In-Reply-To: <1121991994.5892.15.camel@notepaq>
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
Date: Fri, 22 Jul 2005 02:26:34 +0200

> I found the problem. The hci_usb is using the cb[] by itself and so
> overwriting the pkt_type value. The attached patch works for me with the
> hci_usb driver. However I haven't converted all other drivers and
> checked them. This won't happen until I am back home, because I don't
> have any of these devices with me around. However it looks like this
> seems to work without any problems.

Great.  I'll wait until you get back and code up an updated
patch that takes care of all of the drivers.

Thanks.
