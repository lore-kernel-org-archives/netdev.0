From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Wed, 14 Jul 2010 00:51:33 -0300
Message-ID: <AANLkTikmuK0iWDjmG6lVgPyoZAHQ7ZdJmQobVrAQmgNh@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	<AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
	<1279032023.2634.384.camel@edumazet-laptop>
	<AANLkTilrIByt4xAHhsBsKo3nDfv0_c3sF-dCiTiYiPnu@mail.gmail.com>
	<1279036193.2634.468.camel@edumazet-laptop>
	<AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
	<1279077678.2444.95.camel@edumazet-laptop>
	<AANLkTikkcaionMp3SJLgo3JmCjxQ7rPZv3-3_RbxCx_4@mail.gmail.com>
	<1279078985.2444.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39093 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab0GNDvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 23:51:35 -0400
In-Reply-To: <1279078985.2444.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2010/7/14 Eric Dumazet <eric.dumazet@gmail.com>:
>> I can, but my bosses will kick my ass if I bring down the ISP again :)
>
> I have no guarantee at all, even if we find the bug.

Ok :-)

>> If you think it's the only way to find the problem I'll tell them that
>> I need to do it. In this case, please tell me what other config
>> options/tools I can use to get as much info as possible...since I'll
>> probably be able to test this only once more on the production
>> environment for debugging purposes.
>
> You really should try to setup a lab to trigger the bug, and not doing
> experiments on production :)

Right, I'm trying.

The thing is: The ISP is a 200Mbps network with 10,000 users. The
first time it took around 2 minutes to trigger the bug. The second
time it took around 17 minutes.

So I *think* it's some TCP flag with some weird content...but I can't
find out what it is so I can trigger it on the lab.

So my only guess is to enable every possible debug flag I can think of
to track the bug down on the production environment. Any hints here
would be appreciated :)

Cheers,

Felipe Damasio
