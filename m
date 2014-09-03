From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 0/3] qdisc bulk dequeuing and utilizing delayed
 tailptr updates
Date: Wed, 3 Sep 2014 14:47:09 +0200
Message-ID: <20140903144709.7a658763@redhat.com>
References: <20140902143254.1918.8419.stgit@dragon>
	<CA+mtBx8JVqb0TXEOLimAv0hh_g5pfTRg08uNp2idcy=nWhk0_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>, brouer@redhat.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932342AbaICMr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 08:47:28 -0400
In-Reply-To: <CA+mtBx8JVqb0TXEOLimAv0hh_g5pfTRg08uNp2idcy=nWhk0_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Sep 2014 11:04:06 -0700
Tom Herbert <therbert@google.com> wrote:

> On Tue, Sep 2, 2014 at 7:35 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> > from the qdisc layer, to implement dequeue bulking.
> >
> > Open questions:
> >
> > - For now set bulk limit to 8 packets, don't want to stress the driver
> >   avail ring_buffer space.
> >
> Please get limit from BQL also, see:
> [PATCH net-next] net: Functions to report space available in device TX queues

Thank you Tom. I will include that patch in my stack (keeping you as
author), and use the functions you are proposing.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
