From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] rtnetlink: fix potential NULL pointer dereference
Date: Wed, 07 May 2014 17:04:16 -0400 (EDT)
Message-ID: <20140507.170416.948105227236114740.davem@davemloft.net>
References: <cover.1399388943.git.popovich_sergei@mail.ru>
	<d525a30e52966da564bc3e4de31c4197a989b2ae.1399388943.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaEGVES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:04:18 -0400
In-Reply-To: <d525a30e52966da564bc3e4de31c4197a989b2ae.1399388943.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Tue,  6 May 2014 18:13:16 +0300

> Now since commit fbdc1e8c6b79 (rtnetlink: walk through all devs in
> netns safely on link params change) group of network devices can

This is not how you do this, first of all that SHA ID doesn't exist
in any tree other than your's.  It's not an existing commit, but
rather one you are adding in this series.

And secondly, and even more importantly, your patch in this series
is adding this new NULL pointer case.

Therefore you should adjust your first patch to handle this properly
since it introduced the possibility of it happening in the first
place.
