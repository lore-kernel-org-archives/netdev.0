From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/8] s2io: convert to set_phys_id
Date: Mon, 4 Apr 2011 18:08:24 -0700
Message-ID: <20110404180824.65d7a546@nehalam>
References: <20110404210634.840793593@linuxplumber.net>
	<20110404210805.593573200@linuxplumber.net>
	<1301959036.2935.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49972 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab1DEBI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 21:08:29 -0400
In-Reply-To: <1301959036.2935.58.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

		last_gpio_ctrl_val = readq(&bar0->gpio_control);
> [...]
> 
> I think last_gpio_ctrl_val needs to be moved to struct s2io_nic and
> initialised only in the ETHTOOL_ID_ACTIVE case.

Strange there is a value already there and unused?
   sp->adapt_ctrl_org
