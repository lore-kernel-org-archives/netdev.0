From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: add support for interface name retrieval from
 DT aliases
Date: Thu, 08 May 2014 22:42:52 -0400 (EDT)
Message-ID: <20140508.224252.1337086843732451389.davem@davemloft.net>
References: <1399390594-1409-1-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: boris.brezillon@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399390594-1409-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Date: Tue,  6 May 2014 17:36:34 +0200

> There is currently no proper way to bind a net interface to a specific
> name. The interface name is chosen based on the interface type (eth,
> wlan, ...) and the interfaces already registered (the core codes takes
> the first unused interface id of the given type).
> 
> Add support for DT retrieval of the interface id based on DT aliases.
> The alias name must match the interface type (e.g. ethX if you're defining
> an ethernet dev alias).
> 
> Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>

This really isn't kosher at all.

And there absolutely is a proper way to bind a net interface to
a specific name, udev has provided this facility for years.

I'm not applying this, sorry.
