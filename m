From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: macvlan: optimizing the receive path?
Date: Tue, 07 Oct 2014 11:00:42 -0700
Message-ID: <1412704842.11091.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <542DB55D.3090601@akamai.com>
	 <20141004.204203.2211720828886085354.davem@davemloft.net>
	 <5432936D.7010906@gmail.com> <5434246E.1000403@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:49965 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbaJGSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:00:45 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so5349010pde.8
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 11:00:45 -0700 (PDT)
In-Reply-To: <5434246E.1000403@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 13:35 -0400, Jason Baron wrote:

> So if there are no objections, I will post as a formal patch.

I think the code used netif_rx() as a precaution because of
multicast/broadcasts.

Now these are taken care (if multicast filter + work queue for
broadcasts), it seems ok to have a fast path.
