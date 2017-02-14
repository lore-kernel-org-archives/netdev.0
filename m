From: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
Subject: Re: possible unannotated irqs-off
Date: Tue, 14 Feb 2017 17:55:12 -0200
Message-ID: <CAMyjOU+1CAC-VLL0JBABnbzWGZPLncqy6jXWQpVkd6vnXi-3pA@mail.gmail.com>
References: <20170214172858.07d4393a@darkbook.lan.box>
 <20170214.144648.771654199689384203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33412 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753812AbdBNTzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:55:21 -0500
Received: by mail-yw0-f179.google.com with SMTP id u68so72016006ywg.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 11:55:21 -0800 (PST)
Received: from darkbook.lan.box ([179.233.226.113])
        by smtp.gmail.com with ESMTPSA id h3sm524897ywc.54.2017.02.14.11.55.14
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Feb 2017 11:55:14 -0800 (PST)
In-Reply-To: <20170214.144648.771654199689384203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 5:46 PM, David Miller <davem@davemloft.net>
wrote:

> From: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
> Date: Tue, 14 Feb 2017 17:28:58 -0200
>
> > [   93.509167]  ? jtcp_rcv_established+0x8e/0x2d0
> > [   93.509173]  jtcp_rcv_established+0x8e/0x2d0
>
> What are you using this TCP probe for?  That's where the locking
> problem is happening.
>

I just have a kernel build with most tracing/profiling things included
for the sake of LTTng and perf being as verbose as possible.  It's all
vanilla, I haven't patched or modified any of the code.

My way of reproducing it is checking for updates for my Slackware64
system (i.e., "slackpkg update").

Cheers,

-- 
Ricardo Nabinger Sanchez    http://rnsanchez.wait4.org/
        "You never learned anything by doing it right."
