From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and
 provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 17:34:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824173437.453fd7b0.davem@redhat.com>
References: <20040824094952.GF21073@postel.suug.ch>
	<E1BzYMJ-000208-00@gondolin.me.apana.org.au>
	<20040824162501.GI21296@postel.suug.ch>
	<20040824103252.1b593e68.davem@redhat.com>
	<20040824180825.GJ21296@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040824180825.GJ21296@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 20:08:25 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> --- 1.33/include/linux/rtnetlink.h	Mon Apr  5 23:41:40 2004
> +++ 1.35/include/linux/rtnetlink.h	Tue Aug 24 20:06:53 2004
> @@ -540,6 +540,8 @@
>  	IFLA_QDISC,
>  	IFLA_STATS,
>  	IFLA_COST,
> +	IFLA_TXQLEN,
> +	IFLA_MAP,
>  #define IFLA_COST IFLA_COST
>  	IFLA_PRIORITY,
>  #define IFLA_PRIORITY IFLA_PRIORITY

You cannot add new IFLA_* numbers to the middle of the
enumeration, that changes the subsequent existing
IFLA_* values which are hard-coded in userspace applications.

I've fixed this and applied your patch, thanks Thomas.

Could you please provide a 2.4.x version?
