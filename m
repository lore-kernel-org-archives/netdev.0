From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] flow_dissector: do not break if ports are not
 needed in flowlabel
Date: Fri, 22 May 2015 14:12:40 -0400 (EDT)
Message-ID: <20150522.141240.2055906646839231913.davem@davemloft.net>
References: <1432285558-19470-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757231AbbEVSMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:12:41 -0400
In-Reply-To: <1432285558-19470-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 22 May 2015 11:05:58 +0200

> This restored previous behaviour. If caller does not want ports to be
> filled, we should not break.
> 
> Fixes: 06635a35d13d ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
