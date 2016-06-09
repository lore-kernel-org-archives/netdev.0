From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 22:35:52 -0600
Message-ID: <0231E33E-1C1A-4B32-992C-9BFC7470E7E0@cumulusnetworks.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com> <1465442964-5786-2-git-send-email-edumazet@google.com> <c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com> <CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33094 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbcFIEfz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:35:55 -0400
Received: by mail-oi0-f45.google.com with SMTP id k23so45951154oih.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:35:55 -0700 (PDT)
In-Reply-To: <CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 8, 2016, at 10:01 PM, Eric Dumazet <edumazet@google.com> wrote:
> 
>> On Wed, Jun 8, 2016 at 8:41 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> On 6/8/16 9:29 PM, Eric Dumazet wrote:
>>> 
>>> In case a qdisc is used on a vrf device, we need to use different
>>> lockdep classes to avoid false positives.
>>> 
>>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>>> seqcount")
>>> Reported-by: David Ahern <dsa@cumulusnetworks.com>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> 
>> same result with this patch set.
> 
> Are you stacking multiple vrf devices ?

No. You can also look at ipvlan. It shows the same trace. For me it is 3 commands that create the vrf, add eth1, run ping. 
