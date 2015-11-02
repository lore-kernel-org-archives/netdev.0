From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: avoid NULL deref in inet_ctl_sock_destroy()
Date: Mon, 02 Nov 2015 09:00:42 -0800
Message-ID: <1446483642.23275.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446483199.1604795.426897569.53235AF0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34404 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbbKBRAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:00:45 -0500
Received: by padec8 with SMTP id ec8so44607800pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:00:44 -0800 (PST)
In-Reply-To: <1446483199.1604795.426897569.53235AF0@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 17:53 +0100, Hannes Frederic Sowa wrote:
> On Mon, Nov 2, 2015, at 16:50, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Under low memory conditions, tcp_sk_init() and icmp_sk_init()
> > can both iterate on all possible cpus and call inet_ctl_sock_destroy(),
> > with eventual NULL pointer.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> 
> Eric, was this a private report or some of those floating around
> publicly?

Dmitry Vyukov filled two internal bug reports at Google,
not sure if he mentioned the issue elsewhere.

Google-Bug-Id: 25415196
Google-Bug-Id: 25416355

(But you do not have access to them)
