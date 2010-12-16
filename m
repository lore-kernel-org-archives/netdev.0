From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: while bridging Ethernet and wireless device:
Date: Thu, 16 Dec 2010 13:16:37 +0100
Message-ID: <1292501797.3612.12.camel@jlt3.sipsolutions.net>
References: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-16 at 14:11 +0200, Tomas Winkler wrote:

> Dec 15 14:36:41 User-PC kernel: [175576.120452] kernel BUG at include/linux/skbuff.h:1178!

> Dec 15 14:36:41 User-PC kernel: [175576.123193] EIP is at br_multicast_rcv+0xc95/0xe1c [bridge]

So as I said to Tomas in private before -- it kinda looks like something
here is not handling paged SKBs correctly? But I would imaging that
causing more issues, unless there was a bug here that made bridging
require more data in the skb header than we put in there right now -- it
can end up being empty I believe.

Thing is, I looked at the code and it seemed fine.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
