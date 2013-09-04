From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Wed, 04 Sep 2013 03:30:38 -0700
Message-ID: <1378290638.7360.85.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	  <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>
	 <5226D39C.9070401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:52247 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762331Ab3IDKal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 06:30:41 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so110795pbb.38
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 03:30:41 -0700 (PDT)
In-Reply-To: <5226D39C.9070401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 14:30 +0800, Jason Wang wrote:

> > And tcpdump would certainly help ;)
> 
> See attachment.
> 

Nothing obvious on tcpdump (only that lot of frames are missing)

1) Are you capturing part of the payload only (like tcpdump -s 128)

2) What is the setup.

3) tc -s -d qdisc
