From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Thu, 18 Sep 2008 07:53:51 +0000
Message-ID: <20080918075351.GA4633@ff.dom.local>
References: <20080917193832.GA2623@ami.dom.local> <48D1FDB8.4040805@plotinka.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: m0sia <m0sia@plotinka.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:41022 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbYIRHx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 03:53:57 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1966351nfc.21
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 00:53:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D1FDB8.4040805@plotinka.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 01:05:28PM +0600, m0sia wrote:
...
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=11571
>>>>
>>>>            Summary: u32_classify Kernel Panic
...
> It happens on a production server and i can't experiment with this bug.  
> Now i'm using MARK iptable target and fw mark filter, because of this  
> bug. I think it happens when deleting or adding filters(it occur  
> automatically by script, when adding new user or user change speed).  
> I'll try this patch on test server.

OK, no hurry. BTW, it looks like some traffic is needed in a qdisc
while its filters are modified to trigger this. Probably, turning off
CONFIG_CLS_U32_PERF can make this less visible. On the other hand,
turning on memory debugging: CONFIG_DEBUG_SLAB or CONFIG_SLUB_DEBUG_ON
should be helpful here.

Jarek P.
