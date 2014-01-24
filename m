From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] rtnetlink: remove check for fill_slave_info
 in rtnl_have_link_slave_info
Date: Thu, 23 Jan 2014 16:22:43 -0800 (PST)
Message-ID: <20140123.162243.1200181889443294910.davem@davemloft.net>
References: <1390501161-7890-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com,
	vyasevich@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaAXAWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:22:44 -0500
In-Reply-To: <1390501161-7890-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Jan 2014 19:19:21 +0100

> This check is not needed because the same check is done before
> fill_slave_info is used in rtnl_link_slave_info_fill.
> Also, by removing this check, kernel will fillup IFLA_INFO_SLAVE_KIND
> even for slaves of masters which does not implement fill_slave_info.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
