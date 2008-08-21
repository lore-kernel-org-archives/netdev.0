From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_conntrack_sip: fix by making helper pointers thread-local
Date: Thu, 21 Aug 2008 13:28:56 +0200
Message-ID: <48AD5178.4040101@trash.net>
References: <20080820200900.GA32237@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56651 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154AbYHUL26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 07:28:58 -0400
In-Reply-To: <20080820200900.GA32237@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adobriyan@gmail.com wrote:
> Patrick, do I read correctly that ->help hook can run concurrently with itself?
> 
> If yes, apply this patch to fix potential crashes and all sorts of
> nasties.
> 
> 
> 
> [PATCH] nf_conntrack_sip: de-static helper pointers
> 
> Helper's ->help hook can run concurrently with itself, so iterating over
> SIP helpers with static pointer won't work reliably.


Crap. Good catch, thanks a lot. Applied and I'll push it to -stable.
