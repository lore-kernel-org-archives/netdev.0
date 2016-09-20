From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 06:45:18 -0700
Message-ID: <1474379118.23058.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB01049DD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35076 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754920AbcITNpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 09:45:20 -0400
Received: by mail-pf0-f175.google.com with SMTP id z123so7693950pfz.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 06:45:20 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01049DD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 13:36 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 20 September 2016 14:29
> ...
> > > [   47.565420] -2117905507 + -695755206 cannot be represented in type 'int'
> ...
> > I do not think we have to worry here.
> >
> > These is best effort, and unfortunately atomic_t are int.
> 
> Not until we compile on a cpu where int arithmetic doesn't wrap.

Then I guess the guy adding this kind of arches in the kernel will have
to add all the core kernel infra.

If you have an idea, I will happily review a patch.
