From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 15582] New: BUG: unable to handle kernel NULL pointer
 dereference at 0000000000000028
Date: Mon, 22 Mar 2010 21:00:43 -0700 (PDT)
Message-ID: <20100322.210043.66718554.davem@davemloft.net>
References: <bug-15582-27@http.bugzilla.kernel.org/>
	<20100322161416.c4b369f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	stivi@kity.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750719Ab0CWEAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 00:00:20 -0400
In-Reply-To: <20100322161416.c4b369f9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 22 Mar 2010 16:14:16 -0700

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 19 Mar 2010 12:01:10 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=15582
>> 
>>            Summary: BUG: unable to handle kernel NULL pointer dereference
>>                     at 0000000000000028
> 
> A bug in igb or the vlan code, I guess.

Hmmm, should have been fixed by:

commit d1c76af9e2434fac3add561e26c61b06503de986
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Mar 16 10:50:02 2009 -0700

    GRO: Move netpoll checks to correct location
    

...

Nevermind, the backtrace signature is different for this
one.
