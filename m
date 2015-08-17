From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rtnetlink: be more strict when setting MAC address
Date: Mon, 17 Aug 2015 14:09:33 -0700 (PDT)
Message-ID: <20150817.140933.1342685440755543932.davem@davemloft.net>
References: <1439845607-2824-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbbHQVJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:09:34 -0400
In-Reply-To: <1439845607-2824-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Mon, 17 Aug 2015 23:06:47 +0200

> Upon evaluation of IFLA_ADDRESS and IFLA_BROADCAST messages, make sure
> the passed argument length matches dev->addr_len exactly.
> 
> This fixes dubious behaviour of 'ip link set eth0 addr <MAC>' where
> '<MAC>' is too long, e.g. '00:11:22:33:44:55:66:77'. Called like this,
> 'ip' would return successfully and the kernel sets eth0's MAC address to
> the leading six octets of the passed argument.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

I don't think this behavior is very "dubious" and making the check more
strict risks breaking things that have worked for a very long time.

I'm not applying this, sorry.
