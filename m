From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 15:51:50 -0800 (PST)
Message-ID: <20100105.155150.232916389.davem@davemloft.net>
References: <4B43AEF6.6050701@nortel.com>
	<20100105.134218.258781374.davem@davemloft.net>
	<4B43B989.4010004@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755137Ab0AEXvr@vger.kernel.org>
In-Reply-To: <4B43B989.4010004@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Tue, 05 Jan 2010 16:13:29 -0600

> If SOCK_RAW packets are being sent, the protocol number is embedded in
> the packet data

Where exactly is that protocol value?  Not every link level protocol
is ethernet.

We support FDDI, HIPPI, wireless, VLAN, PPP, and a host of others.

So you can't know for sure unless you assume ethernet, which you
can't do.
