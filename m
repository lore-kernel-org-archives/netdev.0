From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 22:44:25 +0100
Message-ID: <87d43oka86.fsf@basil.nowhere.org>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	<4AFA73DA.30308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46105 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759304AbZKKVoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:44:20 -0500
In-Reply-To: <4AFA73DA.30308@gmail.com> (Eric Dumazet's message of "Wed, 11 Nov 2009 09:20:42 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> Problem of possible cpus is the number can be very large on some arches,
> but yet few cpus online....

Actually that should be rare. Especially not very large compared to online.

The only case left is virtualization, but there the ratio of online
cores vs possible is not that large typically.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
