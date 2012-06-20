From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 07:59:00 +0200
Message-ID: <1340171940.4604.799.camel@edumazet-glaptop>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	 <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
	 <20120619.214657.1345825814176201681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38987 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab2FTF7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 01:59:10 -0400
Received: by bkcji2 with SMTP id ji2so5825280bkc.19
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2012 22:59:09 -0700 (PDT)
In-Reply-To: <20120619.214657.1345825814176201681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 21:46 -0700, David Miller wrote:

> These numbers can be decreased further, because since we're already
> looking at the TCP header we can pre-cook the TCP control block in the
> SKB and skip much of the stuff that tcp_v4_rcv() does since we've done
> it already in the early demux code.

It could be done at GRO level and remove one another demux.

As routers probably have no use of GRO, no need of additional knob.
