From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net/sched: let chain_get to figure out the
 return value
Date: Sat, 27 May 2017 11:54:07 +0200
Message-ID: <20170527095407.GA1831@nanopsycho>
References: <20170526072129.11075-1-jiri@resnulli.us>
 <20170526.105912.229870645071385383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32826 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdE0JyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 05:54:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id b84so7634972wmh.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 02:54:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170526.105912.229870645071385383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 26, 2017 at 04:59:12PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 26 May 2017 09:21:29 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Alhough I believe that this create/nocreate dance is completelly
>> pointless, at least make it a bit nicer and easier to read.
>> Push the decision on what error value is returned to chain_get function
>> and use ERR macros.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>No, this is quite worse.
>
>You're leaving pointer error values in structures.  That's extremely
>error prone.

Yet used everywhere in kernel.

>
>And as stated in the other thread, I don't think Cong's logic is strange
>or hard to understand at all.

That is why tc code looks how it does :/
But perhaps I'm slow and everything is crystal-clear to everyone else.
