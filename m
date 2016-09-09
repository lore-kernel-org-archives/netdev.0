From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Fri, 9 Sep 2016 15:07:32 -0700
Message-ID: <e5cc5f33-9a78-cc0f-9244-9a3f7ed4876f@hpe.com>
References: <1473458010-18571-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2355.austin.hpe.com ([15.233.44.28]:3619 "EHLO
        g2t2355.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755176AbcIIWHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 18:07:34 -0400
In-Reply-To: <1473458010-18571-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2016 02:53 PM, Mahesh Bandewar wrote:

> @@ -48,6 +48,11 @@ master device for the L2 processing and routing from that instance will be
>  used before packets are queued on the outbound device. In this mode the slaves
>  will not receive nor can send multicast / broadcast traffic.
>
> +4.3 L3S mode:
> +	This is very similar to the L3 mode except that iptables conn-tracking
> +works in this mode and that is why L3-symsetric (L3s) from iptables perspective.
> +This will have slightly less performance but that shouldn't matter since you
> +are choosing this mode over plain-L3 mode to make conn-tracking work.

What is that first sentence trying to say?  It appears to be incomplete, 
and is that supposed to be "L3-symmetric?"

happy benchmarking,

rick jones
