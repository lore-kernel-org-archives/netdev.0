From: Tony Lindgren <tony@atomide.com>
Subject: Re: [net-next PATCH] drivers: net: cpsw: Add support to make gpio
 drive which slave connected to phy
Date: Tue, 1 Sep 2015 08:36:22 -0700
Message-ID: <20150901153621.GI4215@atomide.com>
References: <1441106719-5896-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:47983 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610AbbIAPgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:36:25 -0400
Content-Disposition: inline
In-Reply-To: <1441106719-5896-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mugunthan V N <mugunthanvnm@ti.com> [150901 04:28]:
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -26,6 +26,9 @@ Optional properties:
>  - dual_emac		: Specifies Switch to act as Dual EMAC
>  - syscon		: Phandle to the system control device node, which is
>  			  the control module device of the am33x
> +- select-slave-gpio	: Should be added if a gpio line is required to
> +			  select which slave is connected to phy
> +

How about using something more generic here for the name?
Something like mode-gpios?

Regards,

Tony
