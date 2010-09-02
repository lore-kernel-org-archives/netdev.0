From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 2 Sep 2010 12:52:33 -0700
Message-ID: <AANLkTimtF7jmoEm+ZexsC_rZGNq8zHxddj7pepomwO35@mail.gmail.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	<1283356463.2556.351.camel@edumazet-laptop>
	<AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	<20100901.183251.106803238.davem@davemloft.net>
	<20100901184802.5a79cf9f@nehalam>
	<D3F292ADF945FB49B35E96C94C2061B90D0670D1@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:13164 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0IBTwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 15:52:40 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o82JqcQh006934
	for <netdev@vger.kernel.org>; Thu, 2 Sep 2010 12:52:38 -0700
Received: from yxj4 (yxj4.prod.google.com [10.190.3.68])
	by kpbe14.cbf.corp.google.com with ESMTP id o82JqWkP003716
	for <netdev@vger.kernel.org>; Thu, 2 Sep 2010 12:52:36 -0700
Received: by yxj4 with SMTP id 4so374828yxj.10
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 12:52:36 -0700 (PDT)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90D0670D1@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> userland folks who actually try to exploit the MQ/MSIX-ness will almost
> always pin down their high-prio[or subset of] threads/processes.
>
I don't really see that.  Pinning is a last resort and in this context
we could only do that on a dedicated server.  On a shared server, with
many different apps, pinning for MQ/MSIX is not an easy option;
meeting scheduler constraints will be the first priority and its up to
networking to work with the scheduler to to the right thing.
Scheduler aware networking (or vice versa) is important.

Tom
