From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 19:34:33 +0200
Message-ID: <1348248873.3103.57.camel@localhost>
References: <20120921085502.4534.20232.stgit@dragon>
	 <1348241111.2669.580.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab2IURei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 13:34:38 -0400
In-Reply-To: <1348241111.2669.580.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 17:25 +0200, Eric Dumazet wrote:
> On Fri, 2012-09-21 at 10:55 +0200, Jesper Dangaard Brouer wrote:
> > Make it possible to adjust the TCP default initial advertised receive
> > window, via sysctl /proc/sys/net/ipv4/tcp_init_recv_window.
> > 
> > The window size is this value multiplied by the MSS of the connection.
> > The default value is (still) 10, as descibed in commit 356f039822b
> > (TCP: increase default initial receive window.)
> > 
> > Allow minimum value of 1, but recommend against setting value below 2
> > in the documentation.
> > 
> > Its possible to control/override this value per route table entry via
> > the iproute2 option initrwnd.  Having the global default exported via
> > sysctl, helps determine the default setting, and make is easier to
> > adjust.
> 
> I was wondering why its not symmetric :
> 
> If we add a sysctl for initial receive window, we need another one for
> initial send window ?

Yes, that was also part of my plan (I just didn't have time to complete
it).  I'll implement the sysctl for initial congestion window, next
week.

Just wanted some initial feedback, on if this sysctl approach is
acceptable or not.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
