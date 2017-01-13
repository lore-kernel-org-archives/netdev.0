From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: To netlink or not to netlink, that is the question
Date: Fri, 13 Jan 2017 14:36:36 +0100
Message-ID: <980e960c-9186-741a-4094-f0c03118de14@6wind.com>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
 <20170112091440.7f6cd41f@xeon-e3>
 <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
 <1484246584.4651.3.camel@redhat.com>
 <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
 <1484291830.19860.3.camel@sipsolutions.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34449 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751444AbdAMNhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 08:37:40 -0500
Received: by mail-lf0-f53.google.com with SMTP id v186so37652401lfa.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 05:36:40 -0800 (PST)
In-Reply-To: <1484291830.19860.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/01/2017 à 08:17, Johannes Berg a écrit :
[snip]
> In addition to what others have said - netlink typically includes (and
> has helpers to do so) a generation counter that's updated whenever this
> list changes, and included in each message, so if userspace really
> cares (often not) it can retry the dump until the system was idle
> enough to get a consistent snapshot.
Look at NLM_F_DUMP_INTR to get details.

> 
> It also looks to me like your existing API isn't even compat-safe due
> to u64 alignment (e.g. in wgpeer), proving once again that ioctl is a
> bad idea.
+1


Regards,
Nicolas
