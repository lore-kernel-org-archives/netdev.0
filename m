From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 14:39:04 -0800
Message-ID: <43A09F08.5000507@candelatech.com>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>	 <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>	 <43A08546.8040708@superbug.co.uk> <1134597344.8855.1.camel@w-sridhar2.beaverton.ibm.com> <43A09811.2080909@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965059AbVLNWra@vger.kernel.org>
To: James Courtier-Dutton <James@superbug.co.uk>
In-Reply-To: <43A09811.2080909@superbug.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Courtier-Dutton wrote:

> Have you actually thought about what would happen in a real world senario?
> There is no real world requirement for this sort of user land feature.
> In memory pressure mode, you don't care about user applications. In 
> fact, under memory pressure no user applications are getting scheduled.
> All you care about is swapping out memory to achieve a net gain in free 
> memory, so that the applications can then run ok again.

Low 'ATOMIC' memory is different from the memory that user space typically
uses, so just because you can't allocate an SKB does not mean you are swapping
out user-space apps.

I have an app that can have 2000+ sockets open.  I would definately like to make
the management and other important sockets have priority over others in my app...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
