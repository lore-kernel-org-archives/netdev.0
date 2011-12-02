From: David Miller <davem@davemloft.net>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Thu, 01 Dec 2011 22:18:02 -0500 (EST)
Message-ID: <20111201.221802.35682473439796092.davem@davemloft.net>
References: <CA+55aFzvZowH1_bA66VZ5Aw0wF3KzdGSqiNZLw46J3u4gpKnxA@mail.gmail.com>
	<20111123.160719.540568233963799514.davem@davemloft.net>
	<CA+55aFxwNbQd-SkFoeS2s18u0ZDto8DdZehJRouDQG-4XW-J_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, pablo@netfilter.org,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxwNbQd-SkFoeS2s18u0ZDto8DdZehJRouDQG-4XW-J_A@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 1 Dec 2011 19:12:48 -0800

> I found a new one: Fedora 16 needs NF_CONNTRACK_NETBIOS_NS (and thus
> NF_CONNTRACK_BROADCAST) for firewalld to work correctly - otherwise it
> fails when you try to find network printers.
 ...
> So can you remove the "depends on NETFILTER_ADVANCED" from
> NF_CONNTRACK_NETBIOS_NS too?

I'll take care of it, thanks.
