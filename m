From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC PATCH] Fix double dereference (Re: IPv6 badness continues)
Date: Thu, 6 Jan 2005 19:53:33 -0800
Message-ID: <20050106195333.2a90f6cb.davem@davemloft.net>
References: <41DA3A60.8050102@pobox.com>
	<20050107.111806.27181187.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050107.111806.27181187.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 07 Jan 2005 11:18:06 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Am I miss something?

Does every path which destroys an ipv6 socket do the
sk_dst_reset()?  If so, your patch should be valid.
