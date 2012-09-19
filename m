From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/9] net/macb: driver enhancement concerning GEM
 support, ring logic and cleanup
Date: Wed, 19 Sep 2012 13:50:06 -0400 (EDT)
Message-ID: <20120919.135006.394934820049386022.davem@davemloft.net>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, havard@skinnemoen.net,
	bhutchings@solarflare.com, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, patrice.vilchez@atmel.com,
	linux-kernel@vger.kernel.org
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1348055112.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Wed, 19 Sep 2012 13:55:13 +0200

> This is an enhancement work that began several years ago. I try to catchup with
> some performance improvement that has been implemented then by Havard.
> The ring index logic and the TX error path modification are the biggest changes
> but some cleanup/debugging have been added along the way.
> The GEM revision will benefit from the Gigabit support.
> 
> The series has been tested on several Atmel AT91 SoC with the two MACB/GEM
> flavors.
> 
> v2: - modify the tx error handling: now uses a workqueue
>     - information provided by ethtool -i were not accurate: removed

Don't submit patches like this.

When you put an RFC right in the middle of the series, it screws everything
up.

It means that I can't only apply the parts that are not RFC.
