From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lto, wan/sbni: Make inline assembler symbols visible
 and assembler global
Date: Mon, 05 Aug 2013 15:33:23 -0700 (PDT)
Message-ID: <20130805.153323.276242626385124232.davem@davemloft.net>
References: <1375741094-8166-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130Ab3HEWdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 18:33:24 -0400
In-Reply-To: <1375741094-8166-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 Aug 2013 15:18:14 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> - Inline assembler defining C callable code has to be global
> - The function has to be visible
> 
> Do this in wan/sbni
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Please just make it use the standard lib/ CRC routines instead.

Thanks.
