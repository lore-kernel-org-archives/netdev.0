From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/3] mlxsw: spectrum: Reduce number of
 supported 802.1D bridges
Date: Wed, 18 May 2016 20:50:40 -0700 (PDT)
Message-ID: <20160518.205040.715594342450511871.davem@davemloft.net>
References: <1459844404-4698-1-git-send-email-jiri@resnulli.us>
	<1459844404-4698-2-git-send-email-jiri@resnulli.us>
	<20160518124050.GA3889@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	corbet@lwn.net, sfeldma@gmail.com, nicolas.dichtel@6wind.com,
	vivien.didelot@savoirfairelinux.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcESDum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 23:50:42 -0400
In-Reply-To: <20160518124050.GA3889@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 18 May 2016 14:40:50 +0200

> This patch, commit b555cf4a50c17a9714715a2d7c8574dca1a7b356 ("mlxsw: spectrum:
> Reduce number of supported 802.1D bridges") reduced the resources the
> device allocates during init. Newer firmware versions now force a hard
> limit on these resources and thus require this patch.
> 
> We would like to ask this commit be backported to stable kernels, so
> that they can be used with newer firmware versions.

Breaking existing working drivers with a firmware update is a terrible
user experience, and in my opinion not a reason to do a -stable
backport.  Fix how you manage this stuff instead.

This new behavior should be requested by drivers that can handle it,
rather than retroactively forced upon existing setups.
