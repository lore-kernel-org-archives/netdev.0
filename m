From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/1] ipv4: IP_RECVERR should also enqueue source quench messages
Date: Wed, 22 Jul 2009 11:32:59 +0200
Message-ID: <87y6qh12r8.fsf@basil.nowhere.org>
References: <1248219127-3203-1-git-send-email-hagen@jauu.net>
	<20090721.200729.212201103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hagen@jauu.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57991 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbZGVJdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 05:33:01 -0400
In-Reply-To: <20090721.200729.212201103.davem@davemloft.net> (David Miller's message of "Tue, 21 Jul 2009 20:07:29 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> I'm almost entirely sure that this behavior is intentional.

I could also imagine that changing it could break some existing
applications that do not expect to see source quenchs here.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
