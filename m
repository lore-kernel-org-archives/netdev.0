From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 5 Feb 2005 21:04:11 -0800
Message-ID: <20050205210411.7e18b8e6.davem@davemloft.net>
References: <20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
	<20050205201044.1b95f4e8.davem@davemloft.net>
	<20050206.133723.124822665.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org,
        yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050206.133723.124822665.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 06 Feb 2005 13:37:23 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> How about making dst->ops->dev_check() like this:
> 
> static int inline dst_dev_check(struct dst_entry *dst, struct net_device *dev)
> {
> 	if (dst->ops->dev_check)
> 		return dst->ops->dev_check(dst, dev)
> 	else
> 		return dst->dev == dev;
> }

Oh I see.  That would work, and it seems the simplest, and
lowest risk fix for this problem.

Herbert, what do you think?
