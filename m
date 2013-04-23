From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 14:37:43 -0700
Message-ID: <1366753063.8964.14.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	 <1366749094-5982-1-git-send-email-willemb@google.com>
	 <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:48764 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab3DWVhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 17:37:45 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so536731dan.24
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 14:37:45 -0700 (PDT)
In-Reply-To: <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 14:23 -0700, Stephen Hemminger wrote:

> What about just having a smarter ingress qdisc?

What are your ideas ?

Setting ingress qdisc on linux is no fun, and not scalable.

Its ok for playing with netem and low bandwidth.
