From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: flush forwarding table when device carrier off
Date: Thu, 12 Oct 2006 14:48:15 -0700 (PDT)
Message-ID: <20061012.144815.112851880.davem@davemloft.net>
References: <20061012112431.0550b252@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37777
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751115AbWJLVsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 17:48:14 -0400
To: shemminger@osdl.org
In-Reply-To: <20061012112431.0550b252@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 12 Oct 2006 11:24:31 -0700

> Flush the forwarding table when carrier is lost. This helps for
> availability because we don't want to forward to a downed device and
> new packets may come in on other links.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 ...
> +			if (f->is_static & !do_all)
> +				continue;

Applied with "&" changed to "&&" as mentioned elsewhere :)
