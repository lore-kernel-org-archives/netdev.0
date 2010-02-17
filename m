From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 2/2] drivers/net/usb: Use netif_<level>
 logging facilities
Date: Tue, 16 Feb 2010 23:37:22 -0800 (PST)
Message-ID: <20100216.233722.59677659.davem@davemloft.net>
References: <20100212.123837.56526847.davem@davemloft.net>
	<c9b38227b55aa3bb46728329bf5290063124f516.1266221693.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, gregkh@suse.de, tilman@imap.cc,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c9b38227b55aa3bb46728329bf5290063124f516.1266221693.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 15 Feb 2010 00:25:12 -0800

> Convert from:
> 	if (netif_msg_<foo>(priv))
> 		dev_<level>(dev...
> to
> 	netif_<level>(priv, foo, dev...
> 
> Also convert a few:
> 
> 	if (i < REG_TIMEOUT) {
> 		etc...
> 		return ret;
>        }
> to
> 	if (i >= REG_TIMEOUT)
> 		goto fail;
> 	etc...
> 	return ret;
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
