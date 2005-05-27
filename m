From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 09:58:51 -0400
Message-ID: <1117202331.6383.39.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527125010.GO15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 14:50 +0200, Thomas Graf wrote:


>  
> -#define NLMSG_PUT(skb, pid, seq, type, len) \
> +#define NLMSG_NEW(skb, pid, seq, type, len, flags) \

How about introducing NLMSG_NEW and leave NLMSG_PUT where it is?
This way we could do incremental updates. If there are not too many of
those NLMSG_PUT around, then it shouldnt be an issue.

The first change would be definetely on top of the current patch i sent
which is well deserved.
Lets have Dave swallow my patch then either you or i could make those
changes. Sounds reasonable?

cheers,
jamal
