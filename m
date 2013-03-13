From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 12:13:46 +0100
Message-ID: <CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	herbert@gondor.apana.org.au, ebiederm@xmission.com
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:62599 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451Ab3CMLNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 07:13:47 -0400
Received: by mail-we0-f169.google.com with SMTP id t11so869059wey.0
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 04:13:46 -0700 (PDT)
In-Reply-To: <513F1A17.1000809@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 1:05 PM, Thomas Martitz
<thomas.martitz@hhi.fraunhofer.de> wrote:
> Hello folks,
>
> (I'm sending this mail a second time (with a few people in CC) because I
> received no response.)
>
> I'm Thomas Martitz, working on my Master Thesis: an Ethernet NIC. As part of
> my work I want to develop a custom loopback interface (for testing
> purposes).
>
> However I'm facing a problem: It doesn't appear to be possible for a second
> loopback device to exist. Even when copying (and module'ifying)
> drivers/net/loopback.c the resulting device doesn't behave like the standard
> lo interface.
>
> After examing the code I found this line (in loopback_net_init()):
>
> loopback.c:206         net->loopback_dev = dev;
>
> This suggests that each network namespace can only have one loopback
> interface. And indeed after modifying my custom interface to include this
> particular line it begins to work, but obviously at the same time the
> standard lo interface stops working.
>
> So my questions are:
> * Is this on purpose/expected?
> * Is there anyway around it so that I can have a custom loopback interface
> without touching lo's functionality.
> * Generally, what's the proper way (if any) implement a secondary loopback
> interface?

The only really question that matters is, why do you need a second
loopback interface?
Why can't you use any other pseudo interface?

-- 
Thanks,
//richard
