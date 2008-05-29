From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Thu, 29 May 2008 08:48:55 -0600
Message-ID: <483EC257.60009@nortel.com>
References: <482DA5B6.1020606@sngx.net>	<482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net>	<482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net>	<20080518003104.GK28241@solarflare.com> <482FBA09.80201@sngx.net>	<483E0AAE.2020107@sngx.net> <20080528221118.63da4092.akpm@linux-foundation.org> <483EA2D1.8050603@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756978AbYE2Ot3@vger.kernel.org>
In-Reply-To: <483EA2D1.8050603@sngx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Cammarata wrote:
>> You didn't provide a reason from adding this feature to the kernel.

> Sorry, my reasoning was in my original patch only.  The ability to reset 
> network counters is, in my experience, one of the first things you do 
> when trying to troubleshoot networking issues - especially when you have 
> incrementing errors.

The ability to reset counters does make it easier to detect changes 
manually, as any non-zero value is something of interest.  However, if 
you're gathering data via a script there is no functional gain.

>> Many of the kernel's accounting accumulators cannot be reset.  We
>> handle that in userspace tools by using subtraction.

> I don't think that should preclude the ability to reset these, unless it is
> shown that it would break something very badly.

You're trying to add new functionality to the kernel, increasing its 
size and adding more work for maintainers.  Also, you're implicitly 
asking that all of the network drivers be updated to add support for 
this feature.  The burden of proof is on you to show why the feature is 
useful enough that the others involved should take on this additional work.

Chris
