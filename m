From: akepner@sgi.com
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 09:16:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0608090913410.2452@localhost.localdomain>
References: <200608080711.06788.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net>
 <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain> <200608090302.19634.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:27280 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1751127AbWHIQ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 12:26:21 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200608090302.19634.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Aug 2006, Andi Kleen wrote:

>
>> But there's alot of state to update (more or less
>> atomically, too)
>
> Why does it need to be atomic? It might be enough
> to just check a flag and poll for it in the readers and then redo the
> lookup.
> ....

(I qualified "atomic" with "more or less" :-)

Sure, something like that could work.

>
> There will be some hickup, but as long as the downtime
> is limited it shouldn't be too bad.
>

Benchmarks are in order....

-- 
Arthur

