From: Karl Heiss <kheiss@gmail.com>
Subject: Re: [PATCH] net: sctp: Don't transition to PF state when transport
 has exhausted 'Path.Max.Retrans'.
Date: Wed, 28 May 2014 07:54:45 -0400
Message-ID: <CAGugRbVGLkmQFMOsws2PFc7KQMuwTMGpXQnnoD=c0mPsBMrt+g@mail.gmail.com>
References: <20140527.160310.1480565548591849457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:49078 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbaE1Lyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 07:54:45 -0400
Received: by mail-ie0-f180.google.com with SMTP id tp5so9814396ieb.25
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 04:54:45 -0700 (PDT)
In-Reply-To: <20140527.160310.1480565548591849457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You could pull in linux-stable commit 7cce3b75682ff8 (net: sctp:
Potentially-Failed state should not be reached...) which should allow
you to apply this patch cleanly.  Otherwise, I can spin a backport,
but I would think having both in stable may be useful for posterity.

Karl

On Tue, May 27, 2014 at 4:03 PM, David Miller <davem@davemloft.net> wrote:
>
> If you guys want me to submit this for -stable releases v3.10 and earlier
> I'll need someone knowledgable with this code to do the backport(s) as
> this change doesn't come close to applying.
>
> In particular, in v3.10 the (transport->state != SCTP_UNCONFIRMED) part of
> the test isn't even there.
>
> Thanks.
