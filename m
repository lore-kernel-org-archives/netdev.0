From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPV6: fix an oops in rt6_device_match()
Date: Sun, 12 Sep 2004 16:32:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912163216.7f49673a.davem@davemloft.net>
References: <20040911.201029.21582458.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040911.201029.21582458.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 20:10:29 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> This fixes panic in rt6_device_match().
> 
> Well, rt->rt6i_idev is always set if it is dynamically allocated.
> However, when we hit ip6_null_entry here, its rt6i_idev is NULL.
> This patch is minimum fix to avoid the oops for now.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Ok, as long as we fix this more cleanly eventually.

Thank you.
