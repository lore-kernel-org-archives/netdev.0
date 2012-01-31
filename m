From: Simon Chen <simonchennj@gmail.com>
Subject: Re: increase the number of routing tables
Date: Mon, 30 Jan 2012 22:06:31 -0500
Message-ID: <CANj2EbfKGL31ztG1UZOApAUHiMznPSYE5w=QWX_NBz-m2Vs=6g@mail.gmail.com>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
	<1327804887.2805.20.camel@edumazet-laptop>
	<4F24B2E9.3010600@candelatech.com>
	<CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
	<4F259D67.3070603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42427 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab2AaDGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 22:06:34 -0500
Received: by werb13 with SMTP id b13so4079941wer.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 19:06:33 -0800 (PST)
In-Reply-To: <4F259D67.3070603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basically I am trying to build a NATter with multiple uplinks...

I have a ton of private IPs behind the NATter, and I need to NAT a
private IP into different uplinks based on the destination prefix.
Think about choosing a specific ISP for a certain destination.

Therefore I'll need to maintain a per-IP routing table to make sure
the outgoing packet goes to the right uplink, and then use
iptables-rules to translate into the proper public IP.

-Simon

On Sun, Jan 29, 2012 at 2:26 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 01/28/2012 08:20 PM, Simon Chen wrote:
>>
>> Thanks...
>>
>> Here says 252 routing tables top... maybe that's too old:
>> http://linux-ip.net/html/routing-tables.html
>>
>> I wonder if we can use a trie-tree for "ip rule" - linear evaluation
>> does not sound too good. But I'll be using a ton of iptables rules a=
s
>> well, and I believe those are linear evaluation too :-(
>
>
> At least some rules apply only to packets entering certain
> interfaces. =A0It seems we could have per-interface rule collections
> in those cases so that only a few rules would be searched each time.
>
> What type of rules are you planning to use?
>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
