From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: v3.12-stable-queue build errors
Date: Mon, 27 Apr 2015 10:45:18 +0200
Message-ID: <553DF71E.7060409@suse.cz>
References: <20150425141609.GA1147@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	ML netdev <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150425141609.GA1147@roeck-us.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/25/2015, 04:16 PM, Guenter Roeck wrote:
> Several powerpc build fail with:
> 
> drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_start_xmit':
> drivers/net/ethernet/freescale/gianfar.c:2146:3: error: implicit declaration of
> function 'dev_consume_skb_any' [-Werror=implicit-function-declaration]
>    dev_consume_skb_any(skb);
> 
> dev_consume_skb_any() does not exist in 3.12.
> 
> Introduced by 'gianfar: Carefully free skbs in functions called by netpoll'.

Eric, David,

what action should I take here?

1) take also:
commit e6247027e5173c00efb2084d688d06ff835bc3b0
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Dec 5 04:45:08 2013 -0800

    net: introduce dev_consume_skb_any()


2) drop 'gianfar: Carefully free skbs in functions called by netpoll'
from stable-3.12

3) any other idea?

thanks,
-- 
js
suse labs
