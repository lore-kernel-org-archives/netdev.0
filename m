From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Using netlink for intra-kernel requests?
Date: Wed, 09 Dec 2009 14:33:48 +0100
Message-ID: <87bpi8mfur.fsf@basil.nowhere.org>
References: <1260308546.29528.27.camel@jdl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jon Loeliger <jdl@bigfootnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41576 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbZLINdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 08:33:42 -0500
In-Reply-To: <1260308546.29528.27.camel@jdl-desktop> (Jon Loeliger's message of "Tue, 08 Dec 2009 15:42:26 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Loeliger <jdl@bigfootnetworks.com> writes:
>
> I tried to read through some of the similar routing bits, but
> even they confess that they "should use netlink", but then doesn't.

That was the great plan at some point, but it never
happened.
>
> I feel like I am missing or don't know where to find the
> documentation for the intra-kernel netlink messaging.

I don't think the kernel uses intra kernel netlink normally,
just tends to call functions directly. That's more efficient
anyways.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
