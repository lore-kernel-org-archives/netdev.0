From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 03/12] net: flow: implement flow cache for
 get routines
Date: Wed, 14 Jan 2015 15:50:41 -0500 (EST)
Message-ID: <20150114.155041.2186306463445075037.davem@davemloft.net>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
	<20150113213621.13874.40461.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbANUuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:50:44 -0500
In-Reply-To: <20150113213621.13874.40461.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 13 Jan 2015 13:36:22 -0800

> One oddity in the rhashtable implementation is there is no way
> AFAICS to do delayed free's so we use rcu_sync heavily. This should be
> fine, get operations shouldn't be a used heavily.

Thomas please provide some feedback on this, thanks.
