From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 13:40:26 -0600
Message-ID: <571E72AA.4030100@cumulusnetworks.com>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
 <20160425.152611.583503438886577374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmanning@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33291 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933421AbcDYTk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:40:29 -0400
Received: by mail-io0-f169.google.com with SMTP id f89so159681906ioi.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 12:40:28 -0700 (PDT)
In-Reply-To: <20160425.152611.583503438886577374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/16 1:26 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 21 Apr 2016 20:56:12 -0700
>
>> Dave: I realize this goes against your preference to keep routes cached
>>        on a down but this patch really emphasizes my point of all the
>>        dark corners to be handled.
>
> I've learned my lesson, I never should have put the original patch in
> to begin with.
>
> And you're so sloppy here, you didn't even bother adding a Fixes: tag.
>
> The patch at the root of all of this has terrible semantics, and it's
> added tons of regressions.  All of which goes against our most basic
> principles.
>
> I've been patient enough, but I've now reverting everything, sorry.
>
> It's unfortunate if you have things which depend upon this, but too
> bad.  This change has been extremely disruptive for a lot of people,
> including me.
>
> You're going to have to work really hard to ever get me to consider
> applying patches which do this again.
>

It's unfortunate you want to take that action. Last week I came across a 
prior attempt by Stephen to do this same thing -- keep IPv6 addresses. 
That prior attempt was reverted by commit 73a8bd74e261. Cumulus, 
Brocade, and others clearly want this capability.

You have made many comments about the pains due to differences between 
IPv4 and IPv6. I deal with those pains daily. It takes time to close 
those differences and unfortunately there have been and will be bumps in 
the road. If you look back at the commits on top of the original I 
responded quickly to the 1 bug report from Andrey and the rest of the 
followups have come from me (or the delta from Mike at Brocade) which 
are a result of our range of testing with this sysctl enabled.
