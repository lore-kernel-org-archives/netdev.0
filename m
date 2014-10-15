From: Cong Wang <cwang@twopensource.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Wed, 15 Oct 2014 13:36:22 -0700
Message-ID: <CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	<20141014.164705.1874094084240216813.davem@davemloft.net>
	<CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
	<20141014.171559.1355616486999711590.davem@davemloft.net>
	<CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
	<1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<543E4DD8.80203@winsoft.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Krzysztof Kolasa <kkolasa@winsoft.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:34455 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaJOUgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 16:36:23 -0400
Received: by mail-qa0-f54.google.com with SMTP id i13so1467663qae.27
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 13:36:23 -0700 (PDT)
In-Reply-To: <543E4DD8.80203@winsoft.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 3:35 AM, Krzysztof Kolasa <kkolasa@winsoft.pl> wrote:
>
> one-line patch not resolve problem, fix created by Cong Wang resolves
> problem !!!
>
> tested on 64bit system and working OK
>

So my patch fixes your problem on 64bit but not on 32bit,
is this correct?

I will send out the patch. And as Eric said, the problem on 32bit
might be a different issue, we can definitely fix it separately.

Thanks for testing!
