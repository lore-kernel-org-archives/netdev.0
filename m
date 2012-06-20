From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 07:51:29 +0200
Message-ID: <1340171489.4604.796.camel@edumazet-glaptop>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	 <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
	 <20120619.214657.1345825814176201681.davem@davemloft.net>
	 <1340171359.4604.794.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56132 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab2FTFvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 01:51:39 -0400
Received: by bkcji2 with SMTP id ji2so5822288bkc.19
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2012 22:51:37 -0700 (PDT)
In-Reply-To: <1340171359.4604.794.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 07:49 +0200, Eric Dumazet wrote:

> 2) small lived tcp sessions
> 
>    input dst is now dirtied because of the additional
> dst_clone()/dst_release()

Not realy a concern because we dirty cache line anyway

dst_use_noref()
{
	dst->__use++;
	dst->lastuse = time;
}
