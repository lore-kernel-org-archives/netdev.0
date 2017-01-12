From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 21:07:43 +0100
Message-ID: <CAHmME9oYtxL=sBpOquOjcqtQnYY=AFHC+OqMdeQD6X8HNoY4zw@mail.gmail.com>
References: <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
 <1484246584.4651.3.camel@redhat.com> <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
 <20170112.141127.426662758858102403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:49386 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750794AbdALUHr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 15:07:47 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id abd10784
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 19:57:44 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 41b7abcc (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 19:57:43 +0000 (UTC)
Received: by mail-oi0-f44.google.com with SMTP id 3so36110454oih.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 12:07:44 -0800 (PST)
In-Reply-To: <20170112.141127.426662758858102403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 8:11 PM, David Miller <davem@davemloft.net> wrote:
> This is a fact of life, dumps are always chopped into suitable
> numbers of responses as necessary.  We do this for IPV4 routes,
> network interfaces, etc. and it all works out just fine.
>
> The thing you should be asking yourself is, if something as heavily
> used and fundamental as IPV4 can handle this, probably your scenerio
> can be handled just fine as well.

Okay, fair enough. I'll suck it up, then, and just use netlink in this
way. David - you concur with Stephen that ioctl is really not okay and
I should absolutely do netlink?
