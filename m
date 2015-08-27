From: Michael Marineau <michael.marineau@coreos.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 27 Aug 2015 09:47:45 -0700
Message-ID: <CAGr1u3tkZ7yva4owBmMWvyShoeXxdKf3Yk1XgXiRiv3pkKN0+A@mail.gmail.com>
References: <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
	<1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAGr1u3vDQDj6rJYcx2vCsf9KkWf-X=qSh3QD-jAZf7hpUYaAyg@mail.gmail.com>
	<20150827.094011.2245604840519777428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	Shaun Crampton <Shaun.Crampton@metaswitch.com>,
	linux-kernel@vger.kernel.org,
	Peter White <Peter.White@metaswitch.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37309 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbbH0Qrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:47:46 -0400
Received: by igui7 with SMTP id i7so40716574igu.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:47:45 -0700 (PDT)
In-Reply-To: <20150827.094011.2245604840519777428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 9:40 AM, David Miller <davem@davemloft.net> wrote:
> From: Michael Marineau <michael.marineau@coreos.com>
> Date: Thu, 27 Aug 2015 09:16:06 -0700
>
>> On Thu, Aug 27, 2015 at 6:00 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Make sure you backported commit
>>> 10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
>>> ("udp: fix dst races with multicast early demux")
>>
>> Oh, interesting. Looks like that patch didn't get CC'd to stable
>> though, is there a reason for that or just oversight?
>
> All networking bug fixes are submitted to -stable by hand by me at a
> time of my choosing.  We do not use the "CC: stable" facility, as I
> feel it pushes patches into -stable way too quickly and before the
> change gets sufficient exposure for regressions in Linus's tree.
>
> The patch in question got submitted last night.

Great, thank you!
