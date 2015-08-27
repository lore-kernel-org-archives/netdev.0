From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Wed, 26 Aug 2015 17:26:27 -0700 (PDT)
Message-ID: <20150826.172627.1308479737177053945.davem@davemloft.net>
References: <20150826073757.GB2215@nanopsycho.orion>
	<20150826.104906.9246591425074015.davem@davemloft.net>
	<CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, jiri@mellanox.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbH0A0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:26:30 -0400
In-Reply-To: <CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 26 Aug 2015 11:21:59 -0700

> Using another netdev doesn't seem right.  Do we need a new device
> class for switches, and then create some common tool/interfaces for
> switch device class?

This is probably what we will need to do.

There has also been a discussion lately about making light weight
netdev objects, of which these new switch things can be a super-class
of.
