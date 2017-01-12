From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 20:02:14 +0100
Message-ID: <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
 <20170112091440.7f6cd41f@xeon-e3> <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
 <1484246584.4651.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:51396 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750746AbdALTCS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 14:02:18 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 8a844c15
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 18:52:16 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id fa4f9085 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 18:52:15 +0000 (UTC)
Received: by mail-oi0-f42.google.com with SMTP id u143so33816362oif.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 11:02:16 -0800 (PST)
In-Reply-To: <1484246584.4651.3.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

Thanks for your response. I'd thought about this, at least for
adding/removing wgpeers/wgipmasks and for configuring wgdevices. This
would fit into multiple smaller messages indeed.

But what about fetching the list of all existing peers and ipmasks
atomically? It seems like with multiple calls, if I'm using some kind
of pagination, things could change in the process. That's why using
one big buffer was most appealing... Any ideas about this?

Jason
