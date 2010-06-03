From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] epic100: Test __BIG_ENDIAN instead of (non-existent)
 CONFIG_BIG_ENDIAN
Date: Thu, 03 Jun 2010 03:29:34 -0700 (PDT)
Message-ID: <20100603.032934.184443752.davem@davemloft.net>
References: <ada4ohlrx22.fsf@roland-alpha.cisco.com>
	<4C06F27B.2080704@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCK3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:25 -0400
In-Reply-To: <4C06F27B.2080704@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 02 Jun 2010 20:08:27 -0400

> On 06/02/2010 04:36 PM, Roland Dreier wrote:
>> Probably no one has used this driver on big-endian systems, since it
>> was
>> setting up descriptor swapping if CONFIG_BIG_ENDIAN is set, which it
>> never is, since that symbol is not mentioned anywhere else in the
>> kernel
>> source.  Switch this test to a check for __BIG_ENDIAN so it has a
>> chance
>> at working.
>>
>> Signed-off-by: Roland Dreier<rolandd@cisco.com>
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

Applied.
