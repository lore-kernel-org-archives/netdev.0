From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 PATCH 1/1] tc simple action update and breakage
Date: Sun, 8 May 2016 10:58:48 -0400
Message-ID: <572F5428.6070607@mojatatu.com>
References: <1462718675-7083-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33531 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbcEHO6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 10:58:50 -0400
Received: by mail-io0-f193.google.com with SMTP id x35so16692293ioi.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 07:58:50 -0700 (PDT)
In-Reply-To: <1462718675-7083-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 10:44 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Brings it closer to more serious actions (adding branching
> and allowing for late binding)
>
> Unfortunately this breaks old syntax of the simple action.
> But because simple is a pedagogical example unlikely to be used
> in production environments (i.e its role is to serve as an example
> on how to write actions), then this is ok.
>
> New syntax for simple has new keyword "sdata". Example usage is:
>
> sudo tc actions add action simple sdata "foobar" index 1
> or
> tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
> match ip dst 17.0.0.1/32 flowid 1:10 action simple sdata "foobar"
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>


Please ignore - doesnt pass all tests. I will resend v2


cheers,
jamal
