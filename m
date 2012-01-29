From: Ben Greear <greearb@candelatech.com>
Subject: Re: increase the number of routing tables
Date: Sun, 29 Jan 2012 11:26:31 -0800
Message-ID: <4F259D67.3070603@candelatech.com>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com> <1327804887.2805.20.camel@edumazet-laptop> <4F24B2E9.3010600@candelatech.com> <CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42434 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2A2T0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 14:26:36 -0500
In-Reply-To: <CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2012 08:20 PM, Simon Chen wrote:
> Thanks...
>
> Here says 252 routing tables top... maybe that's too old:
> http://linux-ip.net/html/routing-tables.html
>
> I wonder if we can use a trie-tree for "ip rule" - linear evaluation
> does not sound too good. But I'll be using a ton of iptables rules as
> well, and I believe those are linear evaluation too :-(

At least some rules apply only to packets entering certain
interfaces.  It seems we could have per-interface rule collections
in those cases so that only a few rules would be searched each time.

What type of rules are you planning to use?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
