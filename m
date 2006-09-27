From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9][TG3]: Improve 5704S autoneg.
Date: Wed, 27 Sep 2006 15:59:31 -0700 (PDT)
Message-ID: <20060927.155931.97292809.davem@davemloft.net>
References: <1159389255.3411.18.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24230
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031199AbWI0W7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 18:59:32 -0400
To: mchan@broadcom.com
In-Reply-To: <1159389255.3411.18.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Sep 2006 13:34:15 -0700

> [TG3]: Improve 5704S autoneg.
> 
> Improve 5704S autoneg logic by using a serdes_counter field to keep
> track of the transient states.  This eliminates a 200 msec busy
> loop in the code.  Autoneg will take its course without the driver
> busy waiting for it to finish.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks for getting rid of that annoying 200ms delay.
