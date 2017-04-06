From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Thu, 6 Apr 2017 16:07:26 -0700
Message-ID: <20170406230726.GB78690@google.com>
References: <20170406185633.91065-1-mka@chromium.org>
 <1491505878.11399.4.camel@sipsolutions.net>
 <20170406192452.GE145051@google.com>
 <1491513145.11399.8.camel@sipsolutions.net>
 <20170406224238.GA78690@google.com>
 <1491519117.11399.10.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>,
        Michael Davidson <md@google.com>,
        Greg Hackmann <ghackmann@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36435 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753102AbdDFXH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 19:07:28 -0400
Received: by mail-pg0-f46.google.com with SMTP id g2so47838245pge.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 16:07:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1491519117.11399.10.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Fri, Apr 07, 2017 at 12:51:57AM +0200 Johannes Berg ha dit:

> On Thu, 2017-04-06 at 15:42 -0700, Matthias Kaehlcke wrote:
> > 
> > Thanks, it would also require to move the initialization of
> > ieee80211_default_rc_algo into an ifdef. If you can live with such a
> > solution I'm happy to change it.
> 
> I think that'd be something I can live with, yeah.
> 
> > > 	git grep 'IS_ENABLED(' | grep '&&'
> > 
> > Indeed the warning is not triggered by these constructs. It seems
> > clang only emits the warning when the constant operand is not
> > boolean.
> 
> That points to just adding "> 0" to the condition here as another
> alternative solution, I guess? With a comment to make sure it's not
> removed again, that'd seem like the best thing to do.

Good point, that's more digestible. I'll send an updated change soon.

Matthias
