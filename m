From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet
 becomes unreachable
Date: Wed, 22 Jan 2014 17:53:37 -0800 (PST)
Message-ID: <20140122.175337.1342087110991372414.davem@davemloft.net>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
	<cover.1390304505.git.popovich_sergei@mail.ru>
	<40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbaAWBxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:53:38 -0500
In-Reply-To: <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue, 21 Jan 2014 13:48:51 +0200

> Also optimize loop a bit:
>   move handling of force > 1 out of the change_nexthops() loop.

Do not mix bug fixes with optimizations.
