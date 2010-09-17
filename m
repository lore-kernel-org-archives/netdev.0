From: Michal Suchanek <hramrach@centrum.cz>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Fri, 17 Sep 2010 20:00:42 +0200
Message-ID: <AANLkTinyhM30KV+Etg2qDzEoqOjcPj7gv5EkPbknxYVQ@mail.gmail.com>
References: <20100914120738.6a658f69.akpm@linux-foundation.org>
 <AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com>
 <20100914135730.8af6bc76.akpm@linux-foundation.org> <20100914.141103.123996613.davem@davemloft.net>
 <20100915064655.GA21021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:58587 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884Ab0IQSBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 14:01:04 -0400
Received: by ywh1 with SMTP id 1so816641ywh.19
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 11:01:03 -0700 (PDT)
In-Reply-To: <20100915064655.GA21021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 September 2010 08:46, Herbert Xu <herbert@gondor.apana.org.au> wr=
ote:
> On Tue, Sep 14, 2010 at 02:11:03PM -0700, David Miller wrote:
>>
>> I'll take a closer look at this if Herbert doesn't beat me to it.
>
> I thought we were going to use this patch until Paul's BH warning
> removal made it into mainline?
>
> netpoll: Disable IRQ around RCU dereference in netpoll_rx
>
> We cannot use rcu_dereference_bh safely in netpoll_rx as we may
> be called with IRQs disabled. =C2=A0We could however simply disable
> IRQs as that too causes BH to be disabled and is safe in either
> case.
>
> Thanks to John Linville for discovering this bug and providing
> a patch.
>
With the patch applied I no longet get the warning.

Thanks

Michal
