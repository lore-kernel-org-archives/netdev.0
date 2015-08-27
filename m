From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Wed, 26 Aug 2015 23:36:03 -0700 (PDT)
Message-ID: <20150826.233603.681080899557993733.davem@davemloft.net>
References: <20150827054004.GA2228@nanopsycho.orion>
	<20150826.230115.2076911912997875741.davem@davemloft.net>
	<20150827062704.GE2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbbH0GgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:36:06 -0400
In-Reply-To: <20150827062704.GE2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 27 Aug 2015 08:27:04 +0200

> I'm not saying it is not possible, it certainly is. But I think that
> for example rocker internals have no value to default user, he
> should not care and he cannot find out what is going on there
> without knowledge or rocker.c code. The question is, do we need some
> standard interface to expose random debugging data? I don't think
> so, I think that debugfs is exactly the tool to be used in that
> case.

If it is only interesting to rocker.c maintainer, he can keep a local
patch he applies when he needs such a facility.

This discussion is becomming circular.

If it's useful, it needs a well defined interface.

If it's not useful, it doesn't belong in the tree.

Therefore, debugfs is useless.
