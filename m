From: Adayadil Thomas <adayadil.thomas@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 16:40:21 -0400
Message-ID: <fb7befa20910301340w7b465ca0kff88a9e5ea0c9cad@mail.gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au>
	 <4AEB06E6.6020206@gmail.com>
	 <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>
	 <469958e00910301251he051d69p178ce53e84130765@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Caitlin Bestler <caitlin.bestler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:40566 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbZJ3UkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 16:40:17 -0400
Received: by vws30 with SMTP id 30so740505vws.33
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 13:40:22 -0700 (PDT)
In-Reply-To: <469958e00910301251he051d69p178ce53e84130765@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 3:51 PM, Caitlin Bestler
<caitlin.bestler@gmail.com> wrote:
> Yes, it is legitimate for a Bridge to see two different 10.*.*.*
> networks on different VLANs.
> A Bridge can even see that same MAC address being used by two
> different end stations
> on different VLANs (especially if the global bit is not set).
>
> What is not legitimate is presenting both of those 10.*.*.* networks
> for local delivery.
>

I did not mean this case.

> If you are only bridging the frames then there are no connections to
> track, only frames.
>

This is more like what I was trying to do with the device, but with
stateful firewall functionality
for which I was using iptables/netfilter.

Thanks
