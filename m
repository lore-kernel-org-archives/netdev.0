From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv3 net] ipv6: no need to return rt->dst.error if it is
 prohibit entry
Date: Wed, 26 Jul 2017 12:48:32 -0600
Message-ID: <e4a809d8-ca96-5714-c7c6-d9f67a0b3d96@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <1501060829-11928-1-git-send-email-liuhangbin@gmail.com>
 <07c66e6f-5b78-3317-18c6-bd2f955d5f90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34134 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750918AbdGZSse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:48:34 -0400
Received: by mail-pf0-f181.google.com with SMTP id q85so74244268pfq.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:48:34 -0700 (PDT)
In-Reply-To: <07c66e6f-5b78-3317-18c6-bd2f955d5f90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/26/17 11:09 AM, David Ahern wrote:
> I don't understand why you are focused on the built-in null and prohibit
> route entries. 

I see. You are using fib rules for the prohibit entry; I am using an
explicit route entry.

If I run 'ip ro get fibmatch' for the latter I want to see that route
entry since it is a route in the FIB:

# ip -6 ro get fibmatch vrf red 5000::1
prohibit 5000::/120 dev lo table red metric 1024 error -13 pref medium

So there are multiple cases to verify.
