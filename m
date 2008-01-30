From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Wed, 30 Jan 2008 11:22:29 -0800
Message-ID: <47A0CE75.5080200@candelatech.com>
References: <20080130938.523292915@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:46843 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbYA3TWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 14:22:37 -0500
In-Reply-To: <20080130938.523292915@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> We've recently had a long discussion about the CVE-2005-0356 time stamp denial-of-service
> attack. It turned out that Linux is only vunerable to this problem when tcp_tw_recycle
> is enabled (which it is not by default).
> 
> In general these two options are not really usable in today's internet because they
> make the (often false) assumption that a single IP address has a single TCP time stamp /
> PAWS clock. This assumption breaks both NAT/masquerading and also opens Linux to denial
> of service attacks (see the CVE description) 
> 
> Due to these numerous problems I propose to remove this code for 2.6.26

We use these features to enable creating very high numbers of short-lived
TCP connections, primarily used as a test tool for other network
devices.

Perhaps just document the adverse affects and/or have it print out a warning
on the console whenever the feature is enabled?


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

