From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Sat, 23 Jul 2005 03:36:20 +0200
Message-ID: <1122082580.5878.3.camel@notepaq>
References: <1121989791.5892.8.camel@notepaq>
	<20050721.165207.35016196.davem@davemloft.net>
	<1121991994.5892.15.camel@notepaq>
	<20050722.155411.32722751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050722.155411.32722751.davem@davemloft.net>
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

Hi David,

> > I found the problem. The hci_usb is using the cb[] by itself and so
> > overwriting the pkt_type value. The attached patch works for me with the
> > hci_usb driver. However I haven't converted all other drivers and
> > checked them. This won't happen until I am back home, because I don't
> > have any of these devices with me around. However it looks like this
> > seems to work without any problems.
> 
> Great.  I'll wait until you get back and code up an updated
> patch that takes care of all of the drivers.

actually the patch is ready by now and hci_usb and hci_vhci are tested.
The tests for the other drivers have to wait at least until first week
of August. However since it seems to work even with 2.6.13-rc3, I don't
see any reason to wait with the inclusion. If you are serious with the
shrinking of the sk_buff, I can send you the final patch along with my
pending patches for 2.6.13.

Regards

Marcel
