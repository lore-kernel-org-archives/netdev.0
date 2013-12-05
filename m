From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 05 Dec 2013 00:39:25 -0500 (EST)
Message-ID: <20131205.003925.220601244226026270.davem@davemloft.net>
References: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
	<20131205.001111.273727362951023546.davem@davemloft.net>
	<7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Somnath.Kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab3LEFj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:39:28 -0500
In-Reply-To: <7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Date: Thu, 5 Dec 2013 05:38:21 +0000

>  Is it the fact that we chose to log a kernel message when the user
>  tries to configure more MC addresses ?

Yes.

This is absolutely not something an individual driver should
decide to do, _EVERY_ driver has this issue.
