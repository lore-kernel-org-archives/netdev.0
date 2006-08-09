From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 18:33:20 -0700
Message-ID: <44D93B60.7030507@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>	<20060808193345.1396.16773.sendpatchset@lappy> <20060808135721.5af713fb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:60649 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1030400AbWHIBeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:34:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060808135721.5af713fb@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> How much of this is just building special case support for large allocations
> for jumbo frames? Wouldn't it make more sense to just fix those drivers to
> do scatter and add the support hooks for that?

Short answer: none of it is.  If it happens to handle jumbo frames nicely
that is mainly a lucky accident, and we do need to check that they actually
works.

Minor rant: the whole skb_alloc familly has degenerated into an unholy
mess and could use some rethinking.  I believe the current patch gets as
far as three _'s at the beginning of a function, this shows it is high
time to reroll the api.

Regards,

Daniel
