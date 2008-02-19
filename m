From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 16:43:05 -0800 (PST)
Message-ID: <20080218.164305.67586867.davem@davemloft.net>
References: <47B9A20C.10304@trash.net>
	<20080218.125525.192686382.davem@davemloft.net>
	<47B9F5E7.3020905@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47B9F5E7.3020905-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Date: Mon, 18 Feb 2008 22:17:27 +0100

> The way pr_debug is implemented it still results in two function
> calls per packet since the compiler doesn't know that it doesn't
> have visible side-effects besides modifying the (unused) buffer.
> I confirmed this using codiff.

That's a bug.

I think we can fix this easily by using __attribute_const_
on the print_mac() declaration.  Let me play with that.
