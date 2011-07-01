From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] rtnl: provide link dump consistency info
Date: Fri, 01 Jul 2011 15:40:29 -0700 (PDT)
Message-ID: <20110701.154029.1235465964568585857.davem@davemloft.net>
References: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
	<20110621131120.GA19486@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org,
	aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org
To: tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110621131120.GA19486-oJAMn8VJQk8CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Tue, 21 Jun 2011 09:11:20 -0400

> This patch adds a change sequence counter to each net namespace
> which is bumped whenever a netdevice is added or removed from
> the list. If such a change occurred while a link dump took place,
> the dump will have the NLM_F_DUMP_INTR flag set in the first
> message which has been interrupted and in all subsequent messages
> of the same dump.
> 
> Note that links may still be modified or renamed while a dump is
> taking place but we can guarantee for userspace to receive a
> complete list of links and not miss any.
> 
> Testing:
> I have added 500 VLAN netdevices to make sure the dump is split
> over multiple messages. Then while continuously dumping links in
> one process I also continuously deleted and re-added a dummy
> netdevice in another process. Multiple dumps per seconds have
> had the NLM_F_DUMP_INTR flag set.
> 
> I guess we can wait for Johannes patch to hit net-next via the
> wireless tree.  I just wanted to give this some testing right away.
> 
> Signed-off-by: Thomas Graf <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
