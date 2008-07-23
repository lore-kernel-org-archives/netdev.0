From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: Re: Performance degradation on 2.6.25 kernels for http servers
Date: Wed, 23 Jul 2008 23:20:47 +0200
Message-ID: <379e30200807231420n676323a2h6fd760af50f7437f@mail.gmail.com>
References: <4887968A.10308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:34324 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYGWVUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:20:48 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2598978rvb.1
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 14:20:48 -0700 (PDT)
In-Reply-To: <4887968A.10308@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you have the same configuration?

2008/7/23 Ben Greear <greearb@candelatech.com>:
> We noticed something strange today.
>
> We have a test that launches 10 http clients that request a small
> URL over and over again.  Keep-alive is enabled on clients and
> apache.
>
> When using a 2.6.24 or earlier kernel on the web server, we get around
> 1200 urls per second completed on each of the 10 clients.  With 2.6.25
> kernel
> we get around 1000 urls per second completed.  In other words, about
> a 20% degradation in connections per second.
>
> We see the same affect when we use standard Fedora kernels as when
> we use our own patched kernels.  We see similar degradations when using
> FC5 and FC8, and 32-bit and 64-bit installs.  We see similar degradations
> on different hardware systems.  We have only tried our modified kernels
> and standard Fedora kernels at this time (no un-modified kernels from
> kernel.org).
>
> It could still be something we are doing wrong, but if anyone
> else has a similar test case, I'm curious to know if you see
> similar degradations.
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
