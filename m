From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 17:03:16 -0700
Message-ID: <20130423170316.52c1adca@nehalam.linuxnetplumber.net>
References: <1366749094-5982-1-git-send-email-willemb@google.com>
	<20130423.184140.2020239496583590253.davem@davemloft.net>
	<1366758683.8964.37.camel@edumazet-glaptop>
	<20130423.191540.217250507483659201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, willemb@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:41294 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab3DXADU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 20:03:20 -0400
Received: by mail-pb0-f47.google.com with SMTP id rq13so284087pbb.6
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 17:03:20 -0700 (PDT)
In-Reply-To: <20130423.191540.217250507483659201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Apr 2013 19:15:40 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 Apr 2013 16:11:23 -0700
> 
> > I guess we should at least not include this code on !SMP builds
> 
> I think CONFIG_RPS already an appropriate guard for something like
> this.  And it depends upon SMP et al.
> 

I wasn't meaning to say flow shedding is a bad idea, just would love
to see a general solution. We are all concerned with DoS attacks.
If you haven't been hit yet, somebody you know is already.
