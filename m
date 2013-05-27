From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround on DT ethernet
Date: Mon, 27 May 2013 14:47:35 +0200
Message-ID: <2255648.0KEmXfjCx5@wuerfel>
References: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com> <51A33447.80305@gmail.com> <1369655404.3557.33.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	andrew@lunn.ch, jason@lakedaemon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, buytenh@wantstofly.org,
	grant.likely@linaro.org, David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369655404.3557.33.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 May 2013 21:50:04 Benjamin Herrenschmidt wrote:
> However, that wouldn't help much with the allocation/leak problem,
> though at least it would be easier to use. It could also *try* to re-use
> the current allocation if the new content is of smaller or equal size.

I thought that dtc tried to aggressively save space by folding identical
strings. If you tried to reuse a property that had its contents shared
with another one, you would get interesting results I guess.

	Arnd
