From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 09:45:17 +0200
Message-ID: <1497512717.2518.5.camel@sipsolutions.net>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
         <1497509862.2518.1.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8EFC@cnshjmbx02>
         <1497510716.2518.4.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8F15@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46216 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdFOHpT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 03:45:19 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BC8F15@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 07:20 +0000, YUAN Linyu wrote:
> > 
> In my opinion if spatch can do it even it found one place, keep it.
> Only leave difficult places like ndisc.c to me.

It's not so simple - I'd have to tailor the spatch to it pretty much I
guess, spending far more time on the spatch than the single place
warrants.

> > Btw, just made a patch to add and use "skb_put_data()", just doing
> > a
> > memcpy() into the skb_put() area also has lots of users.
> 
> Yes, I also notice some places.

I sent a patch.

johannes
