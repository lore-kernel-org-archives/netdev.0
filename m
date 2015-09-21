From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Replace get_seconds with ktime_get_seconds
Date: Sun, 20 Sep 2015 21:54:09 -0700 (PDT)
Message-ID: <20150920.215409.880507139977194497.davem@davemloft.net>
References: <1442506373-3326-1-git-send-email-ksenija.stanojevic@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dhowells@redhat.com, arnd@arndb.de
To: ksenija.stanojevic@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471AbbIUEyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 00:54:11 -0400
In-Reply-To: <1442506373-3326-1-git-send-email-ksenija.stanojevic@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ksenija Stanojevic <ksenija.stanojevic@gmail.com>
Date: Thu, 17 Sep 2015 18:12:53 +0200

> Replace time_t type and get_seconds function which are not y2038 safe
> on 32-bit systems. Function ktime_get_seconds use monotonic instead of
> real time and therefore will not cause overflow.
> 
> Signed-off-by: Ksenija Stanojevic <ksenija.stanojevic@gmail.com>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next, thanks.
