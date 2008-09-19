From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 17:24:00 -0500
Message-ID: <2acbd3e40809191524w346a66abp230f334009840ba7@mail.gmail.com>
References: <20080918.193815.175549834.davem@davemloft.net>
	 <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com>
	 <20080919181840.GE30956@parisc-linux.org>
	 <20080919151120.6f397192@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Matthew Wilcox" <matthew@wil.cx>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Arjan van de Ven" <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:29119 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbYISWYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 18:24:01 -0400
Received: by wf-out-1314.google.com with SMTP id 27so731935wfd.4
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 15:24:00 -0700 (PDT)
In-Reply-To: <20080919151120.6f397192@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 5:11 PM, Arjan van de Ven <arjan@infradead.org> wrote:
> On Fri, 19 Sep 2008 12:18:41 -0600
> Matthew Wilcox <matthew@wil.cx> wrote:

>> In a storage / NUMA configuration we really want to set up one queue
>> per cpu / package / node (depending on resource constraints) and know
>> that the interrupt is going to come back to the same cpu / package /
>> node. We definitely don't want irqbalanced moving the interrupt
>> around.
>
> irqbalance is NUMA aware and places a penalty on placing an interrupt
> "wrongly". We can argue on how strong this penalty should be, but
> thinking that irqbalance doesn't use the numa info the kernel exposes
> is incorrect.
>

I'm only just now wading into this area, but I thought one of the
advantages of multiple hardware queues was that we don't have to worry
about multiple cpus trying to access the buffer rings at the same
time, thus eliminating locking.  If the driver can't rely on that,
don't we lose that advantage?

Andy
