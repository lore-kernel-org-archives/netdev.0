From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BK PATCH] sk_dst_cache annotation
Date: Tue, 18 Jan 2005 12:59:29 -0800
Message-ID: <20050118125929.6868bd60.davem@davemloft.net>
References: <20050115.160008.04476889.yoshfuji@linux-ipv6.org>
	<20050117124913.49c253b6.davem@davemloft.net>
	<20050118.114034.89476074.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050118.114034.89476074.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2005 11:40:34 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Let me clarify:
>   if all the code paths (for each socket type) lock socket,
>   we don't need sk_dst_lock at all (for that socket type).
>   otherwise, we have races; we need sk_dst_lock (for that socket type).
> 
> Am I corrent?

That's correct.
