From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 17:25:11 +0200
Message-ID: <1348241111.2669.580.camel@edumazet-glaptop>
References: <20120921085502.4534.20232.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63473 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756285Ab2IUPZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 11:25:16 -0400
Received: by bkuw11 with SMTP id w11so884604bku.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 08:25:15 -0700 (PDT)
In-Reply-To: <20120921085502.4534.20232.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 10:55 +0200, Jesper Dangaard Brouer wrote:
> Make it possible to adjust the TCP default initial advertised receive
> window, via sysctl /proc/sys/net/ipv4/tcp_init_recv_window.
> 
> The window size is this value multiplied by the MSS of the connection.
> The default value is (still) 10, as descibed in commit 356f039822b
> (TCP: increase default initial receive window.)
> 
> Allow minimum value of 1, but recommend against setting value below 2
> in the documentation.
> 
> Its possible to control/override this value per route table entry via
> the iproute2 option initrwnd.  Having the global default exported via
> sysctl, helps determine the default setting, and make is easier to
> adjust.

I was wondering why its not symmetric :

If we add a sysctl for initial receive window, we need another one for
initial send window ?

Thanks
