From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Fri, 07 Apr 2017 00:51:57 +0200
Message-ID: <1491519117.11399.10.camel@sipsolutions.net>
References: <20170406185633.91065-1-mka@chromium.org>
         <1491505878.11399.4.camel@sipsolutions.net>
         <20170406192452.GE145051@google.com>
         <1491513145.11399.8.camel@sipsolutions.net>
         <20170406224238.GA78690@google.com> (sfid-20170407_004241_473279_B0243983)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>,
        Michael Davidson <md@google.com>,
        Greg Hackmann <ghackmann@google.com>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39758 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751938AbdDFWwC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 18:52:02 -0400
In-Reply-To: <20170406224238.GA78690@google.com> (sfid-20170407_004241_473279_B0243983)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-06 at 15:42 -0700, Matthias Kaehlcke wrote:
> 
> Thanks, it would also require to move the initialization of
> ieee80211_default_rc_algo into an ifdef. If you can live with such a
> solution I'm happy to change it.

I think that'd be something I can live with, yeah.

> > 	git grep 'IS_ENABLED(' | grep '&&'
> 
> Indeed the warning is not triggered by these constructs. It seems
> clang only emits the warning when the constant operand is not
> boolean.

That points to just adding "> 0" to the condition here as another
alternative solution, I guess? With a comment to make sure it's not
removed again, that'd seem like the best thing to do.

johannes
