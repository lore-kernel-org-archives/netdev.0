From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: Make sure both ports initialize correctly
Date: Wed, 30 Sep 2009 20:04:57 -0700 (PDT)
Message-ID: <20090930.200457.240754896.davem@davemloft.net>
References: <4ABA27AC.7030207@ring3k.org>
	<20090930172821.7c6bd127@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755502AbZJADEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 23:04:38 -0400
In-Reply-To: <20090930172821.7c6bd127@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 30 Sep 2009 17:28:21 -0700

> On Wed, 23 Sep 2009 22:50:36 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> If allocation of the second ports fails, make sure that hw->ports
>>  is not 2 otherwise we'll crash trying to access the second port.
>> 
>> This fix is copied from a similar fix in the sky2 driver (ca519274...),
>> but is untested, as I don't have a skge card.
>> 
>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
