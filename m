From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc
 actions
Date: Wed, 7 Sep 2016 23:05:36 -0700
Message-ID: <57D0FFB0.40603@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <57D03EF5.90602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36673 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932873AbcIHHCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 03:02:21 -0400
Received: by mail-pf0-f172.google.com with SMTP id 128so15089809pfb.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 00:02:21 -0700 (PDT)
In-Reply-To: <57D03EF5.90602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-07 09:23 AM, John Fastabend wrote:
> On 16-09-01 10:57 PM, Cong Wang wrote:
>> Currently there are only two tc actions lockless:
>> gact and mirred. But they are questionable because
>> we don't have anything to prevent a parallel update
>> on an existing tc action in hash table while reading
>> it on fast path, this could be a problem when a tc
>> action becomes complex.
> 
> hmm I'm trying to see where the questionable part is in the current
> code? What is it exactly.

[...]

> What did I miss?
> 

OK tracked this down see the other patch 5/6.
