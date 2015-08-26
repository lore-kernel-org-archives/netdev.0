From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Wed, 26 Aug 2015 10:49:06 -0700 (PDT)
Message-ID: <20150826.104906.9246591425074015.davem@davemloft.net>
References: <20150826055215.GA2215@nanopsycho.orion>
	<20150825.230821.2162893312002303587.davem@davemloft.net>
	<20150826073757.GB2215@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238AbbHZRtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:49:07 -0400
In-Reply-To: <20150826073757.GB2215@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 26 Aug 2015 09:37:57 +0200

> I don't think that are much more cases like this. Therefore I think that
> for this cases, debugfs might be a good way to expose debugging stats.

Scott wanted to do similar things in rocker.  DSA guys too.

Every switch device is going to have some kind of hierarchy like
this, it's not a unique situation.

So I don't buy the "this is a special situation" thing at all.
