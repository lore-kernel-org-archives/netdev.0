From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: wan: slic_ds26522: Allow driver to built if
 COMPILE_TEST is enabled
Date: Fri, 14 Oct 2016 10:12:50 -0400 (EDT)
Message-ID: <20161014.101250.152324577042038984.davem@davemloft.net>
References: <1476299159-21094-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        qiang.zhao@nxp.com
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476299159-21094-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Wed, 12 Oct 2016 16:05:59 -0300

> The driver only has runtime but no build time dependency with FSL_SOC ||
> ARCH_MXC || ARCH_LAYERSCAPE.  So it can be built for testing purposes if
> the COMPILE_TEST option is enabled.
> 
> This is useful to have more build coverage and make sure that the driver
> is not affected by changes that could cause build regressions.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Applied.
