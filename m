From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Wed, 14 Apr 2010 11:22:26 +0100
Message-ID: <p2q298f5c051004140322hc54f5315taa5c7d85cb74f06@mail.gmail.com>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
	 <4BBE4BB4.1060209@gmail.com>
	 <i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>
	 <20100409212657.GA3560@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47366 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737Ab0DNKW3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 06:22:29 -0400
Received: by bwz25 with SMTP id 25so6694313bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 03:22:27 -0700 (PDT)
In-Reply-To: <20100409212657.GA3560@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What do you mean with "1:2 has grandchildren with overflown rate tables=
"?
I couldn't understand your idea. Is there any mistake in the
configuration I sent?
How would you set rates for this particular example?

Regards
  Antonio Almeida



On Fri, Apr 9, 2010 at 10:26 PM, Jarek Poplawski wrote:
> On Fri, Apr 09, 2010 at 04:40:44PM +0100, Antonio Almeida wrote:
>> So, what about the rate limit miss?
>> As you can see the ceil of class 1:2 is set to 4096Kbit but its
>> sending rate is actually 8071Kbit!
>> It looks like classes 1:10 and 1:11 are ignoring hierarchical rate
>> restrictions of class 1:2
>> Here:
>> class htb 1:2 parent 1:1 rate 4096Kbit ceil 4096Kbit burst 3655b cbu=
rst 3655b
>> =A0Sent 84285894 bytes 55671 pkt (dropped 0, overlimits 0 requeues 0=
)
>> =A0rate 8071Kbit 666pps backlog 0b 0p requeues 0
>> =A0lended: 0 borrowed: 0 giants: 0
>> =A0tokens: -937499999 ctokens: -937499999
>
> Yes, since 1:2 has grandchildren with overflown rate tables, they
> could behave as if they had set rates higher than their parents or
> grandparent (and HTB doesn't restrict it hierarchically).
>
> Jarek P.
>
