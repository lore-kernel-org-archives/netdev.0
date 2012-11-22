From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] 8139cp: revert "set ring address before
 enabling receiver"
Date: Wed, 21 Nov 2012 23:39:01 -0500 (EST)
Message-ID: <20121121.233901.947301057462707828.davem@davemloft.net>
References: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
	<50AD9F82.6030609@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, dwmw2@infradead.org,
	jasowang@redhat.com, gilboad@gmail.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab2KVSpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:45:32 -0500
In-Reply-To: <50AD9F82.6030609@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Wed, 21 Nov 2012 22:44:02 -0500

> On 11/21/2012 03:07 PM, Francois Romieu wrote:
>> This patch reverts b01af4579ec41f48e9b9c774e70bd6474ad210db.
>>
>> The original patch was tested with emulated hardware. Real
>> hardware chokes.
>>
>> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=47041
>>
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

I'm definitely not applying the revert, because it hurts the largest
user of this driver, which is the virtual hardware.

David Woodhouse's patch is the only reasonable way forward at this
point, so I'd apprecite it if you'd give his patch a review too.

Thank you.
