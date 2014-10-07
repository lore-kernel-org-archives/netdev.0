From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Quota in __qdisc_run() (was: qdisc: validate skb without holding
 lock)
Date: Tue, 7 Oct 2014 09:34:41 +0200
Message-ID: <20141007093441.35ce3a02@redhat.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141003.153645.72976986956341944.davem@davemloft.net>
	<1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbaJGHfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:35:03 -0400
In-Reply-To: <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 03 Oct 2014 16:30:44 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Another problem we need to address is the quota in __qdisc_run()
> is no longer meaningfull, if each qdisc_restart() can pump many packets.

I fully agree. My earlier "magic" packet limit was covering/pampering
over this issue.

> An idea would be to use the bstats (or cpu_qstats if applicable)

Please elaborate some more, as I don't completely follow (feel free to
show with a patch ;-)).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
