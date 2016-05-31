From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: Re: codel/fq_codel triggers heaps of WARNs in net/sched/sch_hfsc.c:1426
Date: Tue, 31 May 2016 15:44:27 +0200
Message-ID: <CAO0uZ+_2CDN-jtqRT85FESqS9u-aXzgw_xukJhNgkMs9rRknwg@mail.gmail.com>
References: <CAO0uZ+-SvYncQ+OUbDn5B7-_W3j6Wge8=t0EKi6xCb1ruXUwiQ@mail.gmail.com>
	<20160531100052.GA2431@breakpoint.cc>
	<CAO0uZ+-uNHjYyEZzYnO0HcHE+y6MXw0+YFzYEwj9HOPMrhkNRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34770 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbcEaNo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 09:44:29 -0400
Received: by mail-lf0-f68.google.com with SMTP id 65so17166659lfq.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 06:44:28 -0700 (PDT)
In-Reply-To: <CAO0uZ+-uNHjYyEZzYnO0HcHE+y6MXw0+YFzYEwj9HOPMrhkNRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I'll submit a hfsc patch soon (it does fix a real problem).

Just FYI, the patch from another thread
[PATCH] hfsc: ensure class is added to eltree exactly once
doesn't help the situation, I just tested it. The debugging output is
exactly the same as before.

-mk
