From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 21:01:35 -0700
Message-ID: <CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com>
 <1465442964-5786-2-git-send-email-edumazet@google.com> <c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33032 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbcFIEBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:01:37 -0400
Received: by mail-yw0-f175.google.com with SMTP id g20so26930825ywb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:01:37 -0700 (PDT)
In-Reply-To: <c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 8:41 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 6/8/16 9:29 PM, Eric Dumazet wrote:
>>
>> In case a qdisc is used on a vrf device, we need to use different
>> lockdep classes to avoid false positives.
>>
>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>> seqcount")
>> Reported-by: David Ahern <dsa@cumulusnetworks.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
>
> same result with this patch set.
>

Are you stacking multiple vrf devices ?
