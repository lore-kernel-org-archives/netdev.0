From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Wed, 16 Nov 2016 17:56:57 +0100
Message-ID: <4f51c606-09ee-ff58-b25a-545a87a70fea@stressinduktion.org>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
 <1479305343-13167-7-git-send-email-jiri@resnulli.us>
 <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
 <20161116.112735.19078311822311561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40546 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752278AbcKPQ5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:57:02 -0500
In-Reply-To: <20161116.112735.19078311822311561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.11.2016 17:27, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 16 Nov 2016 15:51:01 +0100
> 
>> I don't see a way around doing a journal like in filesystems somehow,
> 
> We really just need a sequence counter incremented for each insert/remove,
> and restart the dump from the beginning if it changes mid-dump.

I thought about this at first, too, but became afraid if we could end up
looping endlessly because of routing changes happen constantly while
trying to upload the fib into the hardware.
