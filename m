From: Tom Herbert <tom@herbertland.com>
Subject: Time to revisit LISP?
Date: Thu, 3 Nov 2016 12:22:52 -0700
Message-ID: <CALx6S35cT6gn4W6iiaL5sAgTm=jJPZpyVP3pyGXfbyHHsKaciQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: chris@logicalelegance.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34249 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754208AbcKCTWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:22:53 -0400
Received: by mail-qt0-f171.google.com with SMTP id n6so35006379qtd.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 12:22:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

Looking at netdev archives I see that Dave's response to the LISP
patches from June 2014 was:

"Sorry, I'm not too thrilled about LISP and this patch in particular,
from several different angles.  And therefore I'm going to mark this
patch deferred and not apply it at this time."

It seems to the me that he didn't close the door on ever accepting
LISP into the kernel! I am wondering if it is time to take another
look at this, I am starting to see that there is some existing
deployment of LISP.

AFAICT, most of the concerns Dave had were along the lines of the
infrastructure not the protocol. We might be able to address these
now.

For instance, one of the his questions is:

"What is to keep one from having to service a full Map-Request -->
Map-Reply cycle for every packet received?"

This can be solved by judicious rate limiting, for instance the
infrastructure I implemented to rate limit ILA resolver request could
be applied here.

Thanks,
Tom
