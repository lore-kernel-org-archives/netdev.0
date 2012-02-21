From: alekcejk@googlemail.com
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 06:21:08 +0200
Message-ID: <5196304.nDv69tPK8W@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1329164293.2523.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60007 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab2BUEVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 23:21:50 -0500
Received: by bkcjm19 with SMTP id jm19so5016842bkc.19
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 20:21:49 -0800 (PST)
In-Reply-To: <1329164293.2523.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I noticed that with 3.2.x kernels download speed from some internet resources
> > became about half of speed that was with previous kernels (3.1 and older).
> > I tested Fedora 15 kernels 2.6.41.10 = 3.1.10 and 2.6.42.3 = 3.2.3
> > (many times rebooted for testing with first and second kernels).
> > See bug https://bugzilla.redhat.com/show_bug.cgi?id=789659

Hi,

I tested last released 3.2.7 kernel (2.6.42.7-1.fc15.i686).
Speed problems in 3.2.7 the same as in 3.2.6.

I also have Fedora Rawhide installed in virtual machine (e1000 driver used there)
running on host with 3.1.10 kernel.
And I noticed that after one of 3.3 rc's (or even rc's of 3.2) kernel updates download speed of
updates from dl.fedoraproject.org in VM became extremely slow - about 160 kilobytes/sec
instead of 1,2 megabytes/sec as it was before.
But recently (somewhere between 3.3 rc3 and rc4) speed became again
as it should 1,2 MB/s.

Don't know is this problem related with speed in 3.2.x kernels
and it is hard to debug this now.

-- 
Alexey Kurov <nucleo@fedoraproject.org>
