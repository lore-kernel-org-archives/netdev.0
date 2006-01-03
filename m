From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH - 2.6.14.5]x25: fix for broken x25 module
Date: Tue, 03 Jan 2006 12:13:52 -0800 (PST)
Message-ID: <20060103.121352.56284758.davem@davemloft.net>
References: <1136267307.11486.44.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org,
	eis@baty.hanse.de, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1136267307.11486.44.camel@spereira05.tusc.com.au>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaun Pereira <spereira@tusc.com.au>
Date: Tue, 03 Jan 2006 16:48:27 +1100

> -
> - if (sock_flag(osk, SOCK_ZAPPED))
> - sock_set_flag(sk, SOCK_ZAPPED);
> - 
> - if (sock_flag(osk, SOCK_DBG))
> - sock_set_flag(sk, SOCK_DBG);
> + sock_copy_flags(sk, osk);

Please get your email setup such that the patches you post
might actually be capable of being applied.  Your email
client corrupts the tabbing and spaces in patches heavily.

Thanks.
