From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 13:56:42 -0800
Message-ID: <1383947802.16391.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	 <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527BA63F.7040900@intel.com>
	 <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
	 <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527CFF2C.2020605@intel.com>
	 <CAEzD07LmgvvfNhNuxzwjy7fxLsCBLiofeXJ61qbdOBQCiSRefw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:57222 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757843Ab3KHV4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 16:56:44 -0500
Received: by mail-pd0-f172.google.com with SMTP id w10so2698445pde.31
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 13:56:44 -0800 (PST)
In-Reply-To: <CAEzD07LmgvvfNhNuxzwjy7fxLsCBLiofeXJ61qbdOBQCiSRefw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 19:53 +0400, Anton 'EvilMan' Danilov wrote:

> Hm.. I think I need another way to classify packets for using of mq
> qdisc, because it don't support classify at root (not supported error
> on try attach filter).

I think it might be time to add filters on the device, and run them
without any lock (rcu protection only)

John, I think you had some previous work ?

> On next week i'll try to write ipset extension for setting of priority
> and queue_mapping value through the IPSET netfilter target.

Sounds a nice idea as well.
