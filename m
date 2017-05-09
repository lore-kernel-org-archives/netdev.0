From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] tcp: init tcp_options before using it.
Date: Tue, 9 May 2017 21:22:40 +0800
Message-ID: <20170509132240.GA4649@leo.usersys.redhat.com>
References: <1494237477-19023-1-git-send-email-liuhangbin@gmail.com>
 <1494254963.7796.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36389 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752486AbdEINW5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:22:57 -0400
Received: by mail-pf0-f170.google.com with SMTP id m17so85468pfg.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 06:22:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1494254963.7796.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 07:49:23AM -0700, Eric Dumazet wrote:
> On Mon, 2017-05-08 at 17:57 +0800, Hangbin Liu wrote:
> > I searched 4308fc58dced ("tcp: Document use of undefined variable") in
> > archive list, but did not find the thread. So I'm not sure why we only
> > add a description about un-initialized value.
> > 
> > Even we don't use tmp_opt.sack_ok, I think it would be more safe to
> > initialize the value before using it. Just as other caller did.
> 
> Patch is not needed at all.
> 
> Comment and code are pretty clear.
> 
> This part of the code uses a generic function ( tcp_parse_options()) to
> decode TCP options, but we are only caring about TS one.

OK, got it. Thanks for the explanation and sorry for the inconvenience.

Best Regards
Hangbin
