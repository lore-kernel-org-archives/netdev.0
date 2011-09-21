From: Michael Riesch <michael@riesch.at>
Subject: Re: [patch] usbnet: add timestamping support
Date: Wed, 21 Sep 2011 13:09:56 +0200
Message-ID: <20110921130956.Horde.p773A8L8999OecYElBeV8QA@webmail.df.eu>
References: <20110921121151.Horde.2_LlPML8999Oebhn0-QlTpA@webmail.df.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; DelSp=Yes
Cc: davem@davemloft.net, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay04.ispgateway.de ([80.67.31.42]:37109 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab1IULKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:10:01 -0400
In-Reply-To: <20110921121151.Horde.2_LlPML8999Oebhn0-QlTpA@webmail.df.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Michael Riesch <michael@riesch.at>:
> I considered to put these calls between #ifdef's to make them dependent
> on CONFIG_NETWORK_PHY_TIMESTAMPING. I decided not to do so because except
> the check whether the current packet is a PTP packet (and this check
> should be fast) no overhead occurs. But let me know your opinion about
> that one.

Come to think of it the #ifdef's are definitely unnecessary because these
functions are no-ops with CONFIG_NETWORK_PHY_TIMESTAMPING not set.

Regards,
Michael
