From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] macvlan: support for guest vm direct rx/tx
Date: Fri, 27 Nov 2009 22:58:21 -0800 (PST)
Message-ID: <20091127.225821.38680951.davem@davemloft.net>
References: <200911280043.58784.arnd@arndb.de>
	<20091127.161957.243886653.davem@davemloft.net>
	<20091127213824.53c5a23a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, pmullaney@novell.com, kaber@trash.net,
	netdev@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752446AbZK1G6K@vger.kernel.org>
In-Reply-To: <20091127213824.53c5a23a@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 27 Nov 2009 21:38:24 -0800

> Maybe we should figure out a way for protocols to return new skb in netif_receive_skb
> to avoid extra softirq, but avoid stack overflow?

Eric Dumazet and I tried to find ways to handle this, please see the
archives.  It's not an easy problem to solve and none of the patches
we came up with avoided crashes under high stress scenarios.
