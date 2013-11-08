From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 07:07:00 -0800
Message-ID: <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	 <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527BA63F.7040900@intel.com>
	 <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:52359 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab3KHPHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 10:07:03 -0500
Received: by mail-pa0-f48.google.com with SMTP id kq14so2319568pab.21
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 07:07:02 -0800 (PST)
In-Reply-To: <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 18:53 +0400, Anton 'EvilMan' Danilov wrote:

> Over 60 percent of 'perf top' is _raw_spin_lock function.
> Speed of traffic is near 6Gbit/s, packet rate ~ 1.3 Mpps. But this
> speed are limited by shaper.

Please post :

ethtool -S eth0  # or other nics

perf record -a -g sleep 10

perf report | tail -n 200

And possibly it would be nice if you send your tc script so that we can
check ;)
