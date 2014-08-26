From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Tue, 26 Aug 2014 08:28:15 +0200
Message-ID: <20140826082815.18034199@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537AbaHZG23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 02:28:29 -0400
In-Reply-To: <20140825.163458.1117073971092495452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 16:34:58 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> Given Jesper's performance numbers, it's not the way to go.
> 
> Instead, go with a signalling scheme via new boolean skb->xmit_more.

I'll do benchmarking based on this new API proposal today.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
