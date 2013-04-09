From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Tue, 9 Apr 2013 21:18:33 +0300
Message-ID: <CAEnQRZBLLUviOrgQxzA=X9Q6YpSq9vf8kBtgPxeTiitS+P-oFw@mail.gmail.com>
References: <20130409124735.GA21448@secunet.com>
	<20130409.132138.1712236757714558152.davem@davemloft.net>
	<CAEnQRZB4ESaVwgiTScQyTp=Yo16aUhuonMJS7KzfNbs3zRoLFA@mail.gmail.com>
	<20130409.133329.293030369317491509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steffen.klassert@secunet.com, nicolas.dichtel@6wind.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:41868 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761186Ab3DISSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 14:18:34 -0400
Received: by mail-we0-f171.google.com with SMTP id d46so5435957wer.2
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 11:18:33 -0700 (PDT)
In-Reply-To: <20130409.133329.293030369317491509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 9, 2013 at 8:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Baluta <daniel.baluta@gmail.com>
> Date: Tue, 9 Apr 2013 20:31:30 +0300
>
>> As I mentioned earlier in this thread we are using some custom
>> kernel modules that create the interfaces.
>>
>> It's likely that these interfaces, for memory saving purposes, to
>> skip attaching ipv6 device information.
>
> So this is not an upstream bug.

Correct.

With conditions mentioned by Steffen, in upstream, each net_device
has an in6_device assigned so we won't hit the problem.

Daniel.
