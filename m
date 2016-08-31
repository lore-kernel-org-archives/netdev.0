From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/ethernet: Use ether_addr_copy rather than memcpy
Date: Wed, 31 Aug 2016 09:41:25 -0700
Message-ID: <1472661685.4176.10.camel@perches.com>
References: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Greg Rose <grose@lightfleet.com>
To: Greg Rose <gvrose8192@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0239.hostedemail.com ([216.40.44.239]:57511 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S935692AbcHaQla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:41:30 -0400
In-Reply-To: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-31 at 09:32 -0700, Greg Rose wrote:
> I'm not sure why this hasn't been done before because it seems obvious,
> so maybe there is some reason that memcpy is used instead of
> ether_addr_copy in this code.  But let's try this anyway.
>
> Change memcpy to ether_addr_copy.

I looked at this once and gave up given the need to verify all
the possible callers that require an __aligned(2) source address.
