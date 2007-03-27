From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Established connections hash function
Date: 27 Mar 2007 16:11:56 +0200
Message-ID: <p73lkhi6aj7.fsf@bingen.suse.de>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: nikb@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47505 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832AbXC0NNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:13:11 -0400
In-Reply-To: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Nikolaos D. Bougalis" <nikb@webmaster.com> writes:
> 
>     I will be more than happy to provide a patch for this, but I figured I
> would solicit some input first.

To truly defend against this you would likely need a cryptographic
hash, which would be likely too slow. 

If it's a real problem the better fix would be to switch to some
kind of balanced tree (like Evgeniy is proposing) . 

But I think it can be mostly ignored. 

-Andi
