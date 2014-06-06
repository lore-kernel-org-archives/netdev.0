From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: add gfp parameter to tcp_fragment
Date: Fri, 06 Jun 2014 08:52:35 -0700
Message-ID: <1402069955.3645.300.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:43141 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaFFPwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:52:36 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so2653011pbb.27
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 08:52:36 -0700 (PDT)
In-Reply-To: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 17:32 +0300, Octavian Purdila wrote:
> tcp_fragment can be called from process context (from tso_fragment).
> Add a new gfp parameter to allow it to preserve atomic memory if
> possible.
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
> Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---

Seems fine to me.

I am curious to know why you need this ?

It seems real issue here might be different.

Is it because of some performance issue ?

Thanks
