From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: Add fib rules at vrf device create
Date: Wed, 9 Dec 2015 15:05:06 -0700
Message-ID: <5668A592.3080104@cumulusnetworks.com>
References: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
 <20151209.151309.1866782058292162458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33481 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbbLIWFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:05:11 -0500
Received: by pfnn128 with SMTP id n128so36455744pfn.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:05:10 -0800 (PST)
In-Reply-To: <20151209.151309.1866782058292162458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/15 1:13 PM, David Miller wrote:
> The new attributes make things more complex, because ever _VALID_ tool
> much accomodate the existing situation and be able to perform all of
> the commands above if they are executed on an older kernel.
>
> So the new attributes make things worse, not better.

Dave, how does this make it more complex - beyond the complexity of 
giving a user choices?

If a user wants to install rules directly go for it. That path works 
fine. That covers whatever user base has popped up over the last 38 days 
for the IPv4 support in v4.3 and who ever starts on v4.4 with IPv6 support.

With this change if a user wants the driver to take care of the details 
it can -- by the user asking for the driver to deal with the details.

The 2 options peacefully co-exist.

>
> I will ignore all further attempts to find schemes automate the rule
> and route additions, because it is simply the wrong way forward.

You want to say I failed by not including this in the first patch set - 
fine blame accepted. The initial patches focused on core infrastructure 
to enable VRF support in Linux -- a subject which has proved tough 
enough over the past 15 years.
