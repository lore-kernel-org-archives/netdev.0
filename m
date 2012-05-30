From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/22] net/smsc911x: Repair broken failure paths
Date: Wed, 30 May 2012 17:52:41 -0400 (EDT)
Message-ID: <20120530.175241.2087666784890215382.davem@davemloft.net>
References: <1338353260-10097-1-git-send-email-lee.jones@linaro.org>
	<1338353260-10097-20-git-send-email-lee.jones@linaro.org>
	<CACRpkdY=2j4gRGO4P4RfQDKo+sgV4akAQ6dpP4RbL+XywNCC5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lee.jones@linaro.org, linux-arm-kernel@lists.infradead.org,
	arnd@arndb.de, linus.walleij@stericsson.com,
	grant.likely@secretlab.ca, cjb@laptop.org,
	broonie@opensource.wolfsonmicro.com, sameo@linux.intel.com,
	netdev@vger.kernel.org
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055Ab2E3Vz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 17:55:27 -0400
In-Reply-To: <CACRpkdY=2j4gRGO4P4RfQDKo+sgV4akAQ6dpP4RbL+XywNCC5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Wed, 30 May 2012 15:16:39 +0800

> On Wed, May 30, 2012 at 12:47 PM, Lee Jones <lee.jones@linaro.org> wrote:
> 
>> Current failure paths attempt to free resources which we failed to request
>> and disable resources which we failed to enable ones. This leads to kernel
>> oops/panic. This patch does some simple re-ordering to prevent this from
>> happening.
>>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Lee Jones <lee.jones@linaro.org>
> 
> Acked-by: Linus Walleij <linus.walleij@linaro.org>

Applied, thanks.
