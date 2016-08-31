From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH] net/ethernet: Use ether_addr_copy rather than memcpy
Date: Wed, 31 Aug 2016 09:42:23 -0700
Message-ID: <1472661743.3889.1.camel@gmail.com>
References: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
         <1472661685.4176.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Rose <grose@lightfleet.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36087 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161082AbcHaQmZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:42:25 -0400
Received: by mail-pf0-f181.google.com with SMTP id h186so21167672pfg.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 09:42:25 -0700 (PDT)
In-Reply-To: <1472661685.4176.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-31 at 09:41 -0700, Joe Perches wrote:
> On Wed, 2016-08-31 at 09:32 -0700, Greg Rose wrote:
> > I'm not sure why this hasn't been done before because it seems obvious,
> > so maybe there is some reason that memcpy is used instead of
> > ether_addr_copy in this code.  But let's try this anyway.
> >
> > Change memcpy to ether_addr_copy.
> 
> I looked at this once and gave up given the need to verify all
> the possible callers that require an __aligned(2) source address.
> 

Ha, I figured there must be some reason for it.  OK, patch withdrawn.

Thanks!
