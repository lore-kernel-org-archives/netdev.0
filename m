From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bgmac: fix unaligned accesses to network headers
Date: Mon, 18 Feb 2013 12:45:28 -0500 (EST)
Message-ID: <20130218.124528.2278765194870444067.davem@davemloft.net>
References: <1361049038-25924-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831Ab3BRRpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:45:30 -0500
In-Reply-To: <1361049038-25924-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 16 Feb 2013 22:10:38 +0100

> Without this patch I get many unaligned access warnings per packet,
> this patches fixes them all. This should improve performance on some
> systems like mips.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
