From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix compile failure in
 ixgbe_init_mbx_params_pf
Date: Tue, 08 Mar 2011 14:26:11 -0800 (PST)
Message-ID: <20110308.142611.112600503.davem@davemloft.net>
References: <1299623047-25656-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemeloft.net,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55666
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753549Ab1CHWZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 17:25:34 -0500
In-Reply-To: <1299623047-25656-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Tue,  8 Mar 2011 17:24:07 -0500

> This commit:
> 
>     commit d7c8a29fc8bd20ba45ec2f52577ed04a988a9500
>     Author: Emil Tantilov <emil.s.tantilov@intel.com>
>     Date:   Thu Mar 3 09:25:02 2011 +0000
> 
>         ixgbe: improve logic in ixgbe_init_mbx_params_pf
> 
> incorrectly added a line that accessed mbx->udelay.  I'm sure the intent
> was mbx->usec_delay.  This patch fixes the compilation error.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks Andy.
