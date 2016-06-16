From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 09/11] net: skfb: remove obsolete -I cflag
Date: Wed, 15 Jun 2016 22:06:48 -0700 (PDT)
Message-ID: <20160615.220648.2135362761704622234.davem@davemloft.net>
References: <20160615154553.3177021-1-arnd@arndb.de>
	<20160615154553.3177021-10-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mmarek@suse.com, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, dri-devel@lists.freedesktop.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615154553.3177021-10-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 15 Jun 2016 17:45:51 +0200

> The skfp driver has been moved to drivers/net/fddi/skfp a long time
> ago, but we still attempt to include headers from the old location,
> which causes a warning when building with W=1:
> 
> cc1: error: /git/arm-soc/drivers/net/skfp: No such file or directory [-Werror=missing-include-dirs]
> cc1: error: drivers/net/skfp: No such file or directory [-Werror=missing-include-dirs]
> 
> Clearly this include directive is not needed any more, so we can
> just remove it now.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
