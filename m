From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC] net: remove busylock
Date: Fri, 20 May 2016 19:49:51 +0200
Message-ID: <20160520194951.6354fba1@redhat.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	<20160520092903.38620c60@redhat.com>
	<1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463752069.18194.294.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463753815.18194.298.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbcETRt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 13:49:56 -0400
In-Reply-To: <1463753815.18194.298.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 May 2016 07:16:55 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Since bonding pretends to be multiqueue, TCQ_F_ONETXQUEUE is not set
> on sch->flags when HTB is installed at the bonding device root.

If would be cool if you could run a test with removed busylock and
allow HTB to bulk dequeue.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
