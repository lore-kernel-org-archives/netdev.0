From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 23:46:55 -0700 (PDT)
Message-ID: <20060428.234655.22652563.davem@davemloft.net>
References: <1146262622.8029.63.camel@localhost.localdomain>
	<20060428.154003.25335370.davem@davemloft.net>
	<1146270160.8029.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34769
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751488AbWD2GsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 02:48:19 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1146270160.8029.78.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 29 Apr 2006 10:22:40 +1000

> You're thinking the card would place the packet in the mmap'ed buffer,
> but the protocol handling would still be done (on that user-accessible
> buffer) in kernelspace?

Exactly.

> I hadn't considered that.  Are the userspace-kernel interactions here
> are a lesser problem than telling userspace "you want direct access to
> the packets?  Great, *you* handle the whole thing".

I've very much weary of putting a second TCP stack in userspace
for the same reasons most folks are weary of TOE.

And frankly we should only go towards that kind of duplication if it
shows a real performance gain.

Nevertheless I do highly encourage folks to experiment with that
as much as possible, I could be dead wrong on my hunch that it
won't help enough to justify allowing it.
