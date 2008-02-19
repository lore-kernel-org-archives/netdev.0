From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 19:23:32 -0800 (PST)
Message-ID: <20080218.192332.174070490.davem@davemloft.net>
References: <20080218.164305.67586867.davem@davemloft.net>
	<20080218.165036.218650084.davem@davemloft.net>
	<1203383012.7181.102.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1203383012.7181.102.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Mon, 18 Feb 2008 17:03:32 -0800

> Does this need to be done for all function calls
> declared with __attribute__((format(printf, x, y)))
> {
> return 0;
> }
> 
> ie: pr_debug, dev_dbg, dev_vdbg?

No, I don't think so.

We're adding the tag to teach the compiler that if the
return value isn't used, it is OK not to emit the call
altogether.
