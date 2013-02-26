From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] bond: check if slave count is 0 in case when
 deciding to take slave's mac
Date: Tue, 26 Feb 2013 17:32:55 -0500 (EST)
Message-ID: <20130226.173255.365855195674301131.davem@davemloft.net>
References: <1361867175-4033-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	gregory.v.rose@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab3BZWc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:32:58 -0500
In-Reply-To: <1361867175-4033-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 26 Feb 2013 09:26:15 +0100

> in bond_enslave(), check slave_cnt before actually using slave address.
> 
> introduced by:
> commit 409cc1f8a41 (bond: have random dev address by default instead of zeroes)
> 
> Reported-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
