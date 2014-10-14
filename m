From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Tue, 14 Oct 2014 14:43:44 -0700
Message-ID: <1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	 <20141014.164705.1874094084240216813.davem@davemloft.net>
	 <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
	 <20141014.171559.1355616486999711590.davem@davemloft.net>
	 <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41760 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaJNVnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:43:46 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so8473961pad.5
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 14:43:45 -0700 (PDT)
In-Reply-To: <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-14 at 14:24 -0700, Cong Wang wrote:

> 
> Since we are still in merge window, I don't think we have to use
> a one-line fix for a bug introduced in this merge window.

You are clearly refactoring here. Its a nice cleanup.

If I was the maintainer, I would prefer the one line fix.

Then when net-next is open, you refactor.

As I said, I wont argue, do whatever you want.

Thanks
