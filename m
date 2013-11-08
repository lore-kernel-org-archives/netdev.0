From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 8 Nov 2013 19:53:57 +0400
Message-ID: <CAEzD07LmgvvfNhNuxzwjy7fxLsCBLiofeXJ61qbdOBQCiSRefw@mail.gmail.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	<1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<527BA63F.7040900@intel.com>
	<CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
	<1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
	<527CFF2C.2020605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33682 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613Ab3KHPx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 10:53:58 -0500
Received: by mail-wi0-f181.google.com with SMTP id m19so464858wiv.8
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 07:53:57 -0800 (PST)
In-Reply-To: <527CFF2C.2020605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/11/8 John Fastabend <john.r.fastabend@intel.com>:

> perf would be interesting but note that multiq still uses the root qdisc
> lock which you original stated you were trying to avoid.
>
> mq and mqprio are really the only two existing qdiscs that work well for
> performance with small packet sizes and multiqueue nics at least in my
> experience/setup with these kinds of micro-benchmarks.
>
> .John
>

Hm.. I think I need another way to classify packets for using of mq
qdisc, because it don't support classify at root (not supported error
on try attach filter).
On next week i'll try to write ipset extension for setting of priority
and queue_mapping value through the IPSET netfilter target.


-- 
Anton.
