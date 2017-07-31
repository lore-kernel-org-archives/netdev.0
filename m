From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Mon, 31 Jul 2017 14:38:18 -0700 (PDT)
Message-ID: <20170731.143818.699405961193908260.davem@davemloft.net>
References: <CADVnQym-aDwv-NhcwM5eTW4XQZcKMS+64-VwObKFxT5maT=TGg@mail.gmail.com>
        <CAK6E8=dyuurH4iT5qf0U=JgOEr3X=mDGtG69-KKz5uj6nFYvwQ@mail.gmail.com>
        <CANn89i+m4gSTevvMJMt_qOF7Q-ugqLm-jNh+2aKZDSXWR48Ouw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, fw@strlen.de,
        netdev@vger.kernel.org, soheil@google.com, weiwan@google.com,
        brakmo@fb.com, lorenzo@google.com, vanj@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdGaViT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:38:19 -0400
In-Reply-To: <CANn89i+m4gSTevvMJMt_qOF7Q-ugqLm-jNh+2aKZDSXWR48Ouw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 31 Jul 2017 13:22:22 -0700

> On Mon, Jul 31, 2017 at 1:04 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> by the time these devices use 4.12 kernels they are likely powerful
>> enough to make header prediction irrelevant...
> 
> Also note that TCP stack complexity has increased a lot, I seriously
> doubt anyone could notice any difference.
> 
> On small devices, the major cost is the wakeup of the cpu to process
> one frame before going back to idle...

I agree with Yuchung and Eric on all counts.
