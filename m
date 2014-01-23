From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] ipv4: use SNMP macro assuming softirq context in
 ip_forward().
Date: Wed, 22 Jan 2014 17:52:50 -0800 (PST)
Message-ID: <20140122.175250.1038289738103391750.davem@davemloft.net>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
	<cover.1390304505.git.popovich_sergei@mail.ru>
	<3c324aaf986e6d5a0678cac6d292dd0b96bd9766.1390304505.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbaAWBwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:52:51 -0500
In-Reply-To: <3c324aaf986e6d5a0678cac6d292dd0b96bd9766.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue, 21 Jan 2014 13:48:50 +0200

> ip_forward() runs entirely in softirq context, we could use
> version of SNMP macro which updates stats counters assuming that.
> 
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

This is not a bug fix, it's an optimization.
