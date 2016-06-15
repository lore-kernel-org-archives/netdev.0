From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Wed, 15 Jun 2016 07:55:27 -0400
Message-ID: <5761422F.3010303@mojatatu.com>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
 <5761418F.2050407@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35215 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbcFOLza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:55:30 -0400
Received: by mail-it0-f67.google.com with SMTP id e5so2782556ith.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 04:55:29 -0700 (PDT)
In-Reply-To: <5761418F.2050407@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-15 07:52 AM, Jamal Hadi Salim wrote:
> On 16-06-15 04:38 AM, Jason Wang wrote:
>> We used to queue tx packets in sk_receive_queue, this is less
>> efficient since it requires spinlocks to synchronize between producer

> 
> So this is more exercising the skb array improvements. For tun
> it would be useful to see general performance numbers on user/kernel
> crossing (i.e tun read/write).
> If you have the cycles can you run such tests?
> 

Ignore my message - you are running pktgen from a VM towards the host.
So the numbers you posted are what i was interested in.
Thanks for the good work.

cheers,
jamal
