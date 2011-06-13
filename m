From: David Miller <davem@davemloft.net>
Subject: Re: 3c503: fix broken IRQ autoprobing
Date: Mon, 13 Jun 2011 18:25:29 -0400 (EDT)
Message-ID: <20110613.182529.1873616584449406901.davem@davemloft.net>
References: <201106122140.51776.linux@rainbow-software.org>
	<1307915111.22348.652.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624Ab1FMW1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 18:27:46 -0400
In-Reply-To: <1307915111.22348.652.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 12 Jun 2011 17:45:11 -0400

> On Sun, 2011-06-12 at 21:40 +0200, Ondrej Zary wrote:
>> Fix broken IRQ autoprobing in 3c503 driver:
>>  - improper IRQ freeing (does not free IRQs causes WARN)
>>  - missing break when an working IRQ is found
>> 
>> The driver works with this patch.
> 
> I made a previous attempt to fix autoprobing (commit
> b0cf4dfb7cd21556efd9a6a67edcba0840b4d98d), but didn't have any hardware
> to test on.  In the process I introduced these new bugs.  Sorry about
> that.
> 
>> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> [...]
> Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks.
