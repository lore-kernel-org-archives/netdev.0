From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address
 workaround on DT ethernet
Date: Mon, 27 May 2013 13:18:57 -0700 (PDT)
Message-ID: <20130527.131857.945196320286011406.davem@davemloft.net>
References: <1369647565.3557.28.camel@pasglop>
	<51A33447.80305@gmail.com>
	<1369655404.3557.33.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, buytenh@wantstofly.org,
	jason@lakedaemon.net, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	grant.likely@linaro.org
To: benh@kernel.crashing.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369655404.3557.33.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 27 May 2013 21:50:04 +1000

> It would be handy to be able to just do something like
> 
> 	of_set_property(node, name, ptr, len);
> 
> However, that wouldn't help much with the allocation/leak problem,
> though at least it would be easier to use. It could also *try* to re-use
> the current allocation if the new content is of smaller or equal size.

And this is so much better of an interface because it allows the
OF implementation to decide how to deal with memory allocation
and freeing.
