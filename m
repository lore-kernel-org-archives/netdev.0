From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 6/6] rtnetlink: remove IFLA_SLAVES definition
Date: Thu, 23 Jan 2014 12:47:16 -0800 (PST)
Message-ID: <20140123.124716.330893227222440804.davem@davemloft.net>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
	<1390387435-23918-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbaAWUrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:47:17 -0500
In-Reply-To: <1390387435-23918-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 22 Jan 2014 11:43:55 +0100

> Not used anymore, and never should be.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

First of all your Subject doesn't match the patch, the subject mentions
IFLA_SLAVES whereas the patch deletes IFLA_BOND_SLAVE.

Secondly, you can't remove this, otherwise the next IFLA_* value added
here will reuse that old number potentially breaking userland apps.

I'm not applying this, sorry.
