From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: use ktime_get_seconds() for timestamp
Date: Fri, 11 Sep 2015 15:03:22 -0700 (PDT)
Message-ID: <20150911.150322.1083790165932796949.davem@davemloft.net>
References: <2387233.xmDni0GXyg@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2387233.xmDni0GXyg@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 11 Sep 2015 11:33:01 +0200

> commit c48f350ff5e7 "bnx2x: Add MFW dump support" added the
> bnx2x_update_mfw_dump() function that reads the current time and stores
> it in a 32-bit field that gets passed into a buffer in a fixed format.
> 
> This is potentially broken when the epoch overflows in 2038, and
> otherwise overflows in 2106. As we're trying to avoid uses of
> struct timeval for this reason, I noticed the addition of this
> function, and tried to rewrite it in a way that is more explicit
> about the overflow and that will keep working once we deprecate
> struct timeval.
> 
> I assume that it is not possible to change the ABI any more, otherwise
> we should try to use a 64-bit field for the seconds right away.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
