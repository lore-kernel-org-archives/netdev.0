From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 22:58:07 +0200
Message-ID: <20170327205807.GA11139@localhost.localdomain>
References: <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
 <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com>
 <20170327182828.GA2254@netboy>
 <48C4929F-680A-4F8F-8CE8-7DF3A3E5D83E@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:33802 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdC0U6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:58:55 -0400
Received: by mail-wr0-f177.google.com with SMTP id l43so75201579wre.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 13:58:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48C4929F-680A-4F8F-8CE8-7DF3A3E5D83E@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 12:18:47PM -0700, Denny Page wrote:
> I think that on average, the Vendor’s numbers are likely to be more
> accurate than anyone else’s. The concept that independent software
> implementations are going to somehow obtain and maintain better
> numbers is too much of a stretch.

But you just said that Intel's first published numbers were wrong.  If
the vendors would have published accurate information, then you would
not have to have made your own measurements, and the drivers could
simply use the correct values.

Sadly, this will never happen.  The vendor's track record is 100%
fail.  The apps will always need to implement their own, truly correct
values.  Having "almost correct" values hard coded into the drivers
only makes things worse.

> FWIW, My testing indicates that the 100Mb numbers that Intel
> currently publishes are quite accurate. I don’t believe that Intel
> did the driver corrections btw, if memory serves these values were
> lifted from the Mac.

Huh?  Mac?  -ENOPARSE.

Thanks,
Richard
