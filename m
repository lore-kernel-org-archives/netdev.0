From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Tue, 17 Jan 2017 15:59:04 +0100
Message-ID: <20170117145903.GA17991@penelope.horms.nl>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com, mrv@mojatatu.com,
        hadarh@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36011 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751329AbdAQO7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 09:59:50 -0500
Received: by mail-wm0-f54.google.com with SMTP id c85so203570558wmi.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 06:59:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 06:11:48AM -0500, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to save
> user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it.  The user can store whatever they wish in the
> 128 bits.
> 
> Sample exercise(showing variable length use of cookie)

Hi Jamal,

I think that Daniel made some worthwhile comments regarding the
implementation but schematically I like what I see:

Reviewed-by: Simon Horman <simon.horman@netronome.com>
