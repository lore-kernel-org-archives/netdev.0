From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 15:39:07 -0700 (PDT)
Message-ID: <20080827.153907.157997966.davem@davemloft.net>
References: <87zlmyr5nz.fsf@basil.nowhere.org>
	<20080827.142941.50104491.davem@davemloft.net>
	<20080827223410.GC26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbYH0WjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:39:12 -0400
In-Reply-To: <20080827223410.GC26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 28 Aug 2008 00:34:10 +0200

> It fixes an old performance problem at least. I'm not aware 
> of any new ones in this area because the code in this 
> function hasn't changed since I last looked.

That's exactly what this thread is about, things got slower for
some reason even though nothing specifically changed in this area.

I wonder if indirectly something changed in how the hash table
allocator code down in mm/*.c works, perhaps it's taking NUMA
into account differently now?
