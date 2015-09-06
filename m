From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: wan: sbni: fix device usage count
Date: Sat, 05 Sep 2015 17:33:10 -0700 (PDT)
Message-ID: <20150905.173310.1415682891578970908.davem@davemloft.net>
References: <1441260030-8141-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbbIFAdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 20:33:11 -0400
In-Reply-To: <1441260030-8141-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Thu,  3 Sep 2015 11:30:30 +0530

> dev_get_by_name() will increment the usage count if the matching device
> is found. But we were not decrementing the count if we have got the
> device and the device is non-active.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied, thanks.
