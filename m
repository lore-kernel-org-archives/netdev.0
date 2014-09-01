From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 1 Sep 2014 09:40:32 +0200
Message-ID: <20140901094032.5f0afdbd@redhat.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
	<CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
	<20140825.153146.2165451041039058085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, cwang@twopensource.com, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaIAHku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 03:40:50 -0400
In-Reply-To: <20140825.153146.2165451041039058085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 25 Aug 2014 15:31:46 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> It occurs to me that perhaps the thing to do is to pass sk_buff ** to
> dev_hard_start_xmit().

Is this to send an array of skb's to dev_hard_start_xmit()?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
