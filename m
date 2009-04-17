From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 15:24:12 -0700 (PDT)
Message-ID: <20090417.152412.96128121.davem@davemloft.net>
References: <alpine.DEB.1.10.0904170952050.11877@qirst.com>
	<49E8A240.8050404@us.ibm.com>
	<alpine.DEB.1.10.0904171158220.13734@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752741AbZDQWYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 18:24:21 -0400
In-Reply-To: <alpine.DEB.1.10.0904171158220.13734@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Fri, 17 Apr 2009 12:02:19 -0400 (EDT)

> On Fri, 17 Apr 2009, Nivedita Singhvi wrote:
> 
>> I need the current behaviour to not change, as it would
>> break some people I support.  DaveM is making the right
>> decision here, and I fully support this.
> 
> People or applications? There are applications that only run on Linux and
> fail on other OS? How does this work? Special casing depending on the OS
> running?

Christoph I just want to let you know that I'm totally ignoring
everything further you say on this issue, becuase you're way out of
line and totally ignoring the real issues here.

What's next?  Tomorrow, if you think Linux's open() system call
behavior doesn't suit your needs, I want you to send a sysctl patch to
Al Viro that changes the system wide behavior and we'll see how far
you get with that.

The fact is, you cannot just say "oops we didn't mean to do that" when
something has behaved a certain way, visible to users, for more that
15 years.

And the fact is, WE DID MEAN to do things this way.

As David Stevens explained, the original creator of multicasting, the
original BSD code, and the RFCs, INTENDED this behavior from the very
beginning.

You want to ignore all of this, as if none of it matters and that what
you want to achieve is so much more important.
