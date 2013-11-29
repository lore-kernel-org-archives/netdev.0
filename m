From: David Miller <davem@davemloft.net>
Subject: Re: [patch net/stable] team: fix master carrier set when user
 linkup is enabled
Date: Fri, 29 Nov 2013 16:35:09 -0500 (EST)
Message-ID: <20131129.163509.701956712548045447.davem@davemloft.net>
References: <1385658098-21653-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtluka@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3K2VfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:35:11 -0500
In-Reply-To: <1385658098-21653-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 28 Nov 2013 18:01:38 +0100

> When user linkup is enabled and user sets linkup of individual port,
> we need to recompute linkup (carrier) of master interface so the change
> is reflected. Fix this by calling __team_carrier_check() which does the
> needed work.
> 
> Please apply to all stable kernels as well. Thanks.
> 
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks Jiri.
