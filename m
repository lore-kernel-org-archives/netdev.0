From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/2] Two minor testsuite fixes
Date: Thu, 9 Feb 2017 17:31:10 -0800
Message-ID: <20170209173110.2e0fffec@xeon-e3>
References: <20170209105055.2477-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33150 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdBJBbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 20:31:18 -0500
Received: by mail-pf0-f170.google.com with SMTP id c73so1377451pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 17:31:17 -0800 (PST)
In-Reply-To: <20170209105055.2477-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2017 11:50:53 +0100
Phil Sutter <phil@nwl.cc> wrote:

> While playing around with testsuite, I noticed two minor nits which this
> series attempts to fix.
> 
> Changes since v1:
> - Replaced patch1 completely.
> 
> Phil Sutter (2):
>   testsuite: Generate nlmsg blob at runtime
>   testsuite: Search kernel config in modules dir also
> 
>  .gitignore                                |   2 +
>  testsuite/Makefile                        |   8 +++
>  testsuite/tests/ip/link/dev_wo_vf_rate.nl | Bin 14076 -> 0 bytes
>  testsuite/tools/Makefile                  |   2 +
>  testsuite/tools/generate_nlmsg.c          | 116 ++++++++++++++++++++++++++++++
>  5 files changed, 128 insertions(+)
>  delete mode 100644 testsuite/tests/ip/link/dev_wo_vf_rate.nl
>  create mode 100644 testsuite/tools/Makefile
>  create mode 100644 testsuite/tools/generate_nlmsg.c
> 

Nice. Applied.
I suspect the tests are rarely run because the core functionality doesn't change often.
But in new environments these would be really useful.
