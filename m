From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: sched: check negative err value to safe one level of indent
Date: Tue, 14 Feb 2017 16:20:34 +0100
Message-ID: <20170214152034.GB7671@nanopsycho>
References: <295e658c-d36b-94da-2efe-fb3cf72cc176@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35558 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbdBNPUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 10:20:38 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so28039766wra.2
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 07:20:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <295e658c-d36b-94da-2efe-fb3cf72cc176@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 14, 2017 at 04:10:13PM CET, colin.king@canonical.com wrote:
>Jiro,
>
>A recent static analysis run with CoverityScan identified a potential
>change in functionality with your recent commit "sched: check negative
>err value to safe one level of indent" that landed in linux-next.
>
>The original path for case RTM_DELTFILTER would always goto errout, but
>your commit seems to goto errout only if err is non-zero zero and the
>err == 0 path falls through to the RTM_GETTFILTER case.  I'm not sure if
>this is an intentional change in behaviour.  From what I can make out,
>there is a missing goto errout before the fall-through to RTM_GETTFILTER.

Will fix. Thanks.


>
>Colin
