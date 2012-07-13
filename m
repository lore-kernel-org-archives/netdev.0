From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [DANGER 8/7]: ipv4: Cache output routes in fib_info nexthops.
Date: Fri, 13 Jul 2012 13:03:12 -0700
Message-ID: <CAGK4HS_RvqDLuGnQ-MddFP6ma9TH=ZVR7fSLAK5BL-ji83612A@mail.gmail.com>
References: <20120712.104758.253504708560401123.davem@davemloft.net>
	<CAGK4HS_-fQYnmcbBwEE=JywzAO7_nnE8QAOCXk3-WQOjCimPiA@mail.gmail.com>
	<20120713.041003.2251275100418141024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59703 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756781Ab2GMUDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 16:03:13 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so4284529yhm.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 13:03:13 -0700 (PDT)
In-Reply-To: <20120713.041003.2251275100418141024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 July 2012 04:10, David Miller <davem@davemloft.net> wrote:
> From: Vijay Subramanian <subramanian.vijay@gmail.com>
> Date: Thu, 12 Jul 2012 17:52:54 -0700
>
>> I did not get a chance to see why it suddenly starts working. Hope
>> this helps. I will dig around more.
>
> The problem is the setting of ->rt_gateway for local subnet routes.
>

When I tested this yesterday, the peer was actually not on the same
subnet and I saw this problem.  I think the problem was also present
for a peer on the same subnet.
Anyway, I applied this patch and the DANGER one after this and the
problem has disappeared, fib_lookup() now returns RTN_LOCAL and ssh
responds immediately.
I tested with 2 peers, one on the same subnet and one on a different
one. So far, it looks good.

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Thanks,
Vijay
