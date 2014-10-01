From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 01 Oct 2014 15:47:20 -0400 (EDT)
Message-ID: <20141001.154720.859891453082640385.davem@davemloft.net>
References: <CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
	<20141001192840.5679a671@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, therbert@google.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaJATrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:47:24 -0400
In-Reply-To: <20141001192840.5679a671@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 1 Oct 2014 19:28:40 +0200

> Thus, code is activated only when q->qlen is >= 1. And I have already
> shown that we see a win with just bulking 2 packets:
>  "Subject: qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue"
>  http://thread.gmane.org/gmane.linux.network/331152/focus=331154
> 
> I actually believe, that I have already measured and shown that going
> though the bulk dequeue is a win, this should show direct_xmit vs.
> bulking:
>  "Subject: qdisc/trafgen: Measuring effect of qdisc bulk dequeue, with trafgen"
>  http://thread.gmane.org/gmane.linux.network/331152

+1 Amen...
