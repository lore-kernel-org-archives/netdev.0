From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mISDN: avoid arch specific __builtin_return_address call
Date: Tue, 13 Jan 2015 09:17:59 -0800
Message-ID: <1421169479.9233.25.camel@perches.com>
References: <1816278.9Bv8N8K5IB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1816278.9Bv8N8K5IB@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-13 at 17:10 +0100, Arnd Bergmann wrote:
> Not all architectures are able to call __builtin_return_address().
> On ARM, the mISDN code produces this warning:
> 
> hardware/mISDN/w6692.c: In function 'w6692_dctrl':
> hardware/mISDN/w6692.c:1181:75: warning: unsupported argument to '__builtin_return_address'
>   pr_debug("%s: %s dev(%d) open from %p\n", card->name, __func__,

I didn't know that tidbit. Thanks.
