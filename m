From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] rtnetlink: allow selected handlers to run
 without rtnl
Date: Thu, 10 Aug 2017 10:23:21 -0600
Message-ID: <76093bc0-332d-79c8-f7dd-2bb526e0f915@gmail.com>
References: <20170809184153.16700-1-fw@strlen.de>
 <20170809.172114.233866755819084584.davem@davemloft.net>
 <901d1f86-543b-8225-f87f-e1ab7df3e1a8@gmail.com>
 <20170810112939.GA20558@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34661 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbdHJQXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:23:23 -0400
Received: by mail-pg0-f65.google.com with SMTP id y192so995170pgd.1
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 09:23:23 -0700 (PDT)
In-Reply-To: <20170810112939.GA20558@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/17 5:29 AM, Florian Westphal wrote:
> David Ahern <dsahern@gmail.com> wrote:
> 
>> On 8/9/17 6:21 PM, David Miller wrote:
>>>
>>> Ok series applied, let's see where this goes :-)
>>>
>>
>> 1 hour in, 1 problem reported
> 
> Its even worse.  Would you rather see a revert?

no.

> 
> I'm sure that you are aware that the widespread rtnl usage is a
> problem because it does hurt scalability. I still think its worth trying
> to disentangle this where possible.

agreed. Going to be pain along the way, but it needs to be done. Thanks
for taking the initiative on it.
