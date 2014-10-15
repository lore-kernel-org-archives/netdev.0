From: Krzysztof Kolasa <kkolasa@winsoft.pl>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Wed, 15 Oct 2014 12:35:04 +0200
Message-ID: <543E4DD8.80203@winsoft.pl>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>	 <20141014.164705.1874094084240216813.davem@davemloft.net>	 <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>	 <20141014.171559.1355616486999711590.davem@davemloft.net>	 <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com> <1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps01.winsoft.pl ([5.133.9.51]:49199 "EHLO vps01.winsoft.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbaJOKfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 06:35:10 -0400
In-Reply-To: <1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 14.10.2014 o 23:43, Eric Dumazet pisze:
> On Tue, 2014-10-14 at 14:24 -0700, Cong Wang wrote:
>
>> Since we are still in merge window, I don't think we have to use
>> a one-line fix for a bug introduced in this merge window.
> You are clearly refactoring here. Its a nice cleanup.
>
> If I was the maintainer, I would prefer the one line fix.
>
> Then when net-next is open, you refactor.
>
> As I said, I wont argue, do whatever you want.
>
> Thanks
>
>
>

one-line patch not resolve problem, fix created by Cong Wang resolves 
problem !!!

tested on 64bit system and working OK
