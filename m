From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] tg3: Add TSO workaround using GSO
Date: Thu, 29 Jun 2006 20:16:08 -0700 (PDT)
Message-ID: <20060629.201608.90120890.davem@davemloft.net>
References: <1151630967.21798.20.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jk@blackdown.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7906
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751448AbWF3DQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 23:16:10 -0400
To: mchan@broadcom.com
In-Reply-To: <1151630967.21798.20.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 29 Jun 2006 18:29:27 -0700

> Use GSO to workaround a rare TSO bug on some chips.  This hardware
> bug may be triggered when the TSO header size is greater than 80
> bytes.  When this condition is detected in a TSO packet, the driver
> will use GSO to segment the packet to workaround the hardware bug.
> 
> Thanks to Juergen Kreileder <jk@blackdown.de> for reporting the
> problem and collecting traces to help debug the problem.
> 
> And thanks to Herbert Xu <herbert@gondor.apana.org.au> for providing
> the GSO mechanism that happens to be the perfect workaround for this
> problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks really nice.  Applied, thanks a lot.
