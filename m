From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fou: Don't use const __read_mostly
Date: Wed, 08 Apr 2015 15:29:21 -0400 (EDT)
Message-ID: <20150408.152921.1694166124541049677.davem@davemloft.net>
References: <1428498271-6345-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbbDHT3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 15:29:22 -0400
In-Reply-To: <1428498271-6345-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed,  8 Apr 2015 06:04:31 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> const __read_mostly is a senseless combination. If something
> is already const it cannot be __read_mostly. Remove the bogus
> __read_mostly in the fou driver.
> 
> This fixes section conflicts with LTO.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Applied, thank you.
