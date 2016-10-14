From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: wan: slic_ds26522: Export OF module alias
 information
Date: Fri, 14 Oct 2016 10:12:43 -0400 (EDT)
Message-ID: <20161014.101243.1068410757449553130.davem@davemloft.net>
References: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
        <1476298541-7354-2-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        qiang.zhao@nxp.com
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476298541-7354-2-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Wed, 12 Oct 2016 15:55:41 -0300

> When the device is registered via OF, the OF table is used to match the
> driver instead of the SPI device ID table, but the entries in the later
> are used as aliasses to load the module if the driver was not built-in.
> 
> This is because the SPI core always reports an SPI module alias instead
> of an OF one, but that could change so it's better to always export it.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Applied.
