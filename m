From: Michael Trimarchi <michael@amarulasolutions.com>
Subject: Re: [PATCH V2] net: stmmac: use msleep instead of udelay for gpio
 reset
Date: Wed, 22 Apr 2015 02:55:03 +0200
Message-ID: <20150422005503.GA11073@panicking>
References: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
 <20150421.173540.1253961571051792975.davem@davemloft.net>
 <20150421231347.GA3392@panicking>
 <20150421.203134.3443090203330589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, festevam@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35390 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbbDVAy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:54:58 -0400
Received: by pabtp1 with SMTP id tp1so256794505pab.2
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 17:54:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150421.203134.3443090203330589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tue, Apr 21, 2015 at 08:31:34PM -0400, David Miller wrote:
> From: Michael Trimarchi <michael@amarulasolutions.com>
> Date: Wed, 22 Apr 2015 01:13:47 +0200
> 
> > Hi
> > 
> > On Tue, Apr 21, 2015 at 05:35:40PM -0400, David Miller wrote:
> >> From: Michael Trimarchi <michael@amarulasolutions.com>
> >> Date: Tue, 21 Apr 2015 13:16:13 +0200
> >> 
> >> > -			udelay(data->delays[0]);
> >>  ...
> >> > +			msleep(max(1U, data->delays[0] / 1000));
> >> 
> >> That looks very ugly with that max() expression in there.
> >>
> > 
> > Is fine for you a DIV_ROUND_UP?
> 
> Not inside of these simple msleep() calls, no.
> 
> How about adjusting the values either in the datastructure or
> in local variables instead?  That wasn't so hard to come up
> with now, was it?

Ok, it's easy no problem at all, I will post later today but I prefer
local variables and use DIV_ROUND_UP

Michael
