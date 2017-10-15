From: Petr Vorel <petr.vorel@gmail.com>
Subject: Re: [PATCH] tests: Remove bashisms (s/source/.)
Date: Sun, 15 Oct 2017 12:05:49 +0200
Message-ID: <20171015100548.lp7wocgancidddni@x230>
References: <20171008143916.21813-1-petr.vorel@gmail.com>
 <C7ED1FFD-C1B2-4543-9DBD-B633E7D0AA30@intel.com>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:47091 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750722AbdJOKFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:05:52 -0400
Received: by mail-wr0-f169.google.com with SMTP id l1so3523713wrc.3
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:05:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <C7ED1FFD-C1B2-4543-9DBD-B633E7D0AA30@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

> > --- a/testsuite/tests/ip/route/add_default_route.t
> > +++ b/testsuite/tests/ip/route/add_default_route.t
> > @@ -1,6 +1,6 @@
> > -#!/bin/sh
> > +#!/bin/bash

> Funny - ^^^ choosing bash explicitly while
>    vvvv removing the bashism?
Eh, this is really silly, sorry. I've sent a patch to revert it back as it was unintentional.


> I noticed a couple other files already specified /bin/bash, yet you removed the bashisms. But the above struck me as something that would not seem to have been intended.
I plan to remove all bashisms. Although having explicit dependency on bash (i.e. /bin/bash
in shebang), it would be nice have posix compliant shell scripts (as Randy Dunlap also
noted). Or at least don't have bashisms in script with /bin/sh shebang.


Kind regards,
Petr
