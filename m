From: Ani Sinha <ani@aristanetworks.com>
Subject: question about kernel patch: ipv4: fix the rcu race between
 free_fib_info and ip_route_output_slow
Date: Tue, 2 Apr 2013 16:49:59 -0700
Message-ID: <CAOxq_8PTRwy6Rs+mM2gxViDoZpnCuT-KD3PkCC1i31XyT_VAkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	Bob Gilligan <gilligan@aristanetworks.com>,
	Prasad Koya <prasad@aristanetworks.com>
To: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:40518 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab3DBXuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 19:50:00 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so767235iae.25
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 16:49:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello :

I was looking at the former netdev thread :
http://www.spinics.net/lists/netdev/msg193411.html

It seems the following patch was applied in Linux 3.5 to fix the oops
in ip_route_output_slow :

commit e49cc0da7283088c5e03d475ffe2fdcb24a6d5b1
Author: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Date:   Wed May 23 15:39:45 2012 +0000

    ipv4: fix the rcu race between free_fib_info and ip_route_output_slow


We hit into a very similar oops in the same place but with 2.6.38
kernel. We are thinking of backporting this patch to our 2.6.38 kernel
tree. Since I am not very familier with this code, I wanted to seek
the opinion of netdev folks and ask whether this will be safe to do
so. We did notice that this patch was backported to longterm supported
3.4 tree as well. We also notice that this patch was committed almost
one year back and has remained intact in Torvalds' latest and greatest
tip.

The patch itself looks simple enough but obviously we do not know the
code path well enough to understand all the impacts of this change.

Any suggestions will be greatly appreciated.

thanks,
ani
