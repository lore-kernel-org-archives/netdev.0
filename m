From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Tue, 25 Aug 2015 23:08:21 -0700 (PDT)
Message-ID: <20150825.230821.2162893312002303587.davem@davemloft.net>
References: <1440427547-8539-3-git-send-email-jiri@resnulli.us>
	<20150825.142521.1764936130530564868.davem@davemloft.net>
	<20150826055215.GA2215@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbbHZGIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 02:08:23 -0400
In-Reply-To: <20150826055215.GA2215@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 26 Aug 2015 07:52:15 +0200

> They are simple statistics. But they does not fit into any existing
> interface. This is about EMAD packets. They are not per-netdevice, but
> per-pcidevice. So I cannot put them into ethtool.
> 
> I see no other iface to expose this other than debugfs. Please suggest
> some other way, I don't see it :/

Then create one, instead of crapping up the driver with debugfs
craziness.

>>I'm not applying this, and I'm really getting irritated about how much
>>garbage people put into debugfs when it has _NO_ business being there.
> 
> I think that is the primary purpose of this iface, To put arbitrary
> debugging garbage there. Am I missing something?

It's not garbage if it's useful for someone.

If it's not useful, why even bother?

This is why I hate debugfs, it's a fundamentally flawed facility.
