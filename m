From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours on
 fib GC
Date: Fri, 11 Jan 2013 13:13:42 -0800
Message-ID: <CAL1RGDVjwddbyVdkzMeXEiqFXQNECjCWAyEFK5V5oAPddfbwZA@mail.gmail.com>
References: <1357753459-12872-1-git-send-email-roland@kernel.org> <20130110.141847.265135906896223944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:54912 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753523Ab3AKVOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 16:14:04 -0500
Received: by mail-fa0-f72.google.com with SMTP id s10so2146172fas.7
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 13:14:02 -0800 (PST)
In-Reply-To: <20130110.141847.265135906896223944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 2:18 PM, David Miller <davem@davemloft.net> wrote:
> Another reason we must make ipv6 like ipv4, which looks up neighbours
> on demand at packet output time rather than caching them in the route
> entries.

Not sure I'm qualified to perform that level of surgery, but I'll take
a look at ipv4 and try to understand how that works.

In the meantime does it make sense to put a smaller bandaid in 3.8?
I'm pretty sure this is a regression (we never saw it with older
kernels), probably due to some part of the route cache improvements
you've been doing.

 - R.
