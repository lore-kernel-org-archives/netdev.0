From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] flow: better memory management
Date: Mon, 13 Sep 2010 00:28:14 +0200
Message-ID: <87tyluk35t.fsf@basil.nowhere.org>
References: <1284138025.24675.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55889 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab0ILW2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 18:28:22 -0400
In-Reply-To: <1284138025.24675.100.camel@edumazet-laptop> (Eric Dumazet's
	message of "Fri, 10 Sep 2010 19:00:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Allocate hash tables for every online cpus, not every possible ones.

There are some setups that boot most of the CPUs after boot.
On those this heuristic would be very wrong.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
