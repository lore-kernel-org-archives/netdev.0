From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] Fix races in ip6_route_{input,output}().
Date: Mon, 29 Nov 2004 19:49:03 -0800
Message-ID: <20041129194903.5899cd25.davem@davemloft.net>
References: <20041128.103626.88640124.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041128.103626.88640124.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 28 Nov 2004 10:36:26 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> We need to hold refcnt before releasing rt6_lock.

Looks good, patch applied, thanks a lot.
