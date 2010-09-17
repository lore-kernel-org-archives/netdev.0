From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Fri, 17 Sep 2010 16:55:36 -0700 (PDT)
Message-ID: <20100917.165536.254856822.davem@davemloft.net>
References: <20100914.141103.123996613.davem@davemloft.net>
	<20100915064655.GA21021@gondor.apana.org.au>
	<AANLkTinyhM30KV+Etg2qDzEoqOjcPj7gv5EkPbknxYVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: hramrach@centrum.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751752Ab0IQXzR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 19:55:17 -0400
In-Reply-To: <AANLkTinyhM30KV+Etg2qDzEoqOjcPj7gv5EkPbknxYVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Suchanek <hramrach@centrum.cz>
Date: Fri, 17 Sep 2010 20:00:42 +0200

> On 15 September 2010 08:46, Herbert Xu <herbert@gondor.apana.org.au> =
wrote:
>> On Tue, Sep 14, 2010 at 02:11:03PM -0700, David Miller wrote:
>>>
>>> I'll take a closer look at this if Herbert doesn't beat me to it.
>>
>> I thought we were going to use this patch until Paul's BH warning
>> removal made it into mainline?
>>
>> netpoll: Disable IRQ around RCU dereference in netpoll_rx
>>
>> We cannot use rcu_dereference_bh safely in netpoll_rx as we may
>> be called with IRQs disabled. =A0We could however simply disable
>> IRQs as that too causes BH to be disabled and is safe in either
>> case.
>>
>> Thanks to John Linville for discovering this bug and providing
>> a patch.
>>
> With the patch applied I no longet get the warning.

Ok I'll toss this upstream since I have no indication that Paul's
RCU change will hit Linus's tree any time soon.

Thanks.
