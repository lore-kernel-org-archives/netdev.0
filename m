From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3 v3] ipv6: convert the uses of ADBG and remove the
 superfluous parentheses
Date: Tue, 13 Aug 2013 20:44:07 -0700
Message-ID: <1376451847.1949.60.camel@joe-AO722>
References: <520AFB20.2000109@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39029 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758442Ab3HNDoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 23:44:09 -0400
In-Reply-To: <520AFB20.2000109@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-14 at 11:36 +0800, Ding Tianhong wrote:
> Just follow the Joe Perches's opinion, it is a better way to fix the
> style errors.

[]

> Signed-off-by: Joe Perches <joe@perches.com>

Nope, not signed by me.  I sent you a suggestion.
Please don't add Signed-off-by: signatures for others.
Maybe you might use Suggested-by:

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c

> @@ -99,9 +99,9 @@
>  #define ACONF_DEBUG 2
>  
>  #if ACONF_DEBUG >= 3
> -#define ADBG(x) printk x
> +#define ADBG(fmt, ...) printk(fmt, ##__VA_ARGS__)
>  #else
> -#define ADBG(x)
> +#define ADBG(fmt, ...) do {} while (0)

btw:  The macro I suggested will always verify format
and arguments.  This will not.

#define ADBG(fmt, ...) do { if (0) printk(fmt, ##__VA_ARGS__); } while (0)
