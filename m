From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 02 Oct 2013 14:38:52 -0700
Message-ID: <1380749932.19002.127.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
	 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380748118.19002.125.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002212436.GC7824@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:54560 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab3JBViy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:38:54 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so1491085pde.37
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 14:38:53 -0700 (PDT)
In-Reply-To: <20131002212436.GC7824@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 16:24 -0500, Shawn Bohrer wrote:

> So... Are you suggesting that I just skip the early demux for unicast
> UDP entirely?  That is fine by me since I only care about the
> multicast case.

Nope this is not what I suggested.

I suggested that for unicast, you do a limited lookup to the first
socket found in bucket.

If its an exact match, you take the socket.

If not, you give up, and do not scan the whole chain.
