From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] net: ipv4: hlen could be set as size_t
Date: Fri, 23 Oct 2015 06:08:52 -0700 (PDT)
Message-ID: <20151023.060852.167547226456492975.davem@davemloft.net>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
	<1445602236-24130-11-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbbJWMwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:52:24 -0400
In-Reply-To: <1445602236-24130-11-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Fri, 23 Oct 2015 14:10:35 +0200

> The hlen member of raw_frag_vec is used in operation/function that wait
> for unsigned value. So it need to be set as size_t.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

You really need to test your changes.

Particularly on a platform where size_t has a different size than
'int'.  That will generate several warnings, as shown by all of the
build warning reports sent by the kbuild test robot in response to
this patch series.

Also, you need to CC: all relevant mailing lists for the entire series
of patches, and also provide a "Subject: [PATCH 0/N] xxx" posting
describing at a high level and in detail what this patch series is
doing, and why.

It should also clearly state what exact tree you expect these patches
to be merged into.

Thanks.
