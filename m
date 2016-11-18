From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH -next] tcp: make undo_cwnd mandatory for congestion modules
Date: Fri, 18 Nov 2016 15:38:01 -0500
Message-ID: <CADVnQykLcgoGiMcnAFe-HA4Pn29aSQEORYBVg=5YV=466NrBWw@mail.gmail.com>
References: <1479387411-9830-1-git-send-email-fw@strlen.de>
 <20161118.134304.1574614508508170507.davem@davemloft.net> <20161118185434.GB18071@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35510 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbcKRUid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 15:38:33 -0500
Received: by mail-oi0-f51.google.com with SMTP id b126so63909671oia.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 12:38:32 -0800 (PST)
In-Reply-To: <20161118185434.GB18071@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 1:54 PM, Florian Westphal <fw@strlen.de> wrote:
> David Miller <davem@davemloft.net> wrote:
>> If you really suspect that highspeed et al. need to implement their own
>> undo_cwnd instead of using the default reno fallback, I would really
>> rather that this gets either fixed or explicitly marked as likely wrong
>> (in an "XXX" comment or similar).
>
> Ok, fair enough.  I am not familiar with these algorithms, I will check
> what they're doing in more detail and if absolutely needed resubmit this
> patch with XXX/FIXME/TODO comments added.

BTW, FWIW I really like the idea of making undo_cwnd required. It
simplifies the core code and forces CC modules to think about what
undo should look like for their CC module.

And I suspect you are right that those CC modules have an issue that
should be fixed.

neal
