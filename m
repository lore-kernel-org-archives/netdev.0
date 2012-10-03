From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: [Patch net-next] netpoll: call ->ndo_select_queue() in tx path
Date: Wed, 3 Oct 2012 11:33:22 +0200
Message-ID: <CAF6-1L5Gp9kpV+Koru6uAmYxQg_WQav9RVD4MVBDa2UGSoPOCA@mail.gmail.com>
References: <1347948991-20860-1-git-send-email-amwang@redhat.com>
	<20120919.172108.1539457128236567338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: amwang@redhat.com, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:40939 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754048Ab2JCJdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 05:33:23 -0400
Received: by vcbfo13 with SMTP id fo13so7995074vcb.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 02:33:22 -0700 (PDT)
In-Reply-To: <20120919.172108.1539457128236567338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> In netpoll tx path, we miss the chance of calling ->ndo_select_queue(),
>> thus could cause problems when bonding is involved.
>>
>> This patch makes dev_pick_tx() extern (and rename it to netdev_pick_tx())
>> to let netpoll call it in netpoll_send_skb_on_dev().
>>
>> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>> Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>
>
> Applied, thanks.

Huh, I don't see it in the final 3.6 ?
That's rather inconvenient :(

Cheers,

    Sylvain
