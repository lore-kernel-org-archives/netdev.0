From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: add destructor for skb data.
Date: Sun, 6 Apr 2008 17:32:17 +0400
Message-ID: <20080406133217.GA19671@2ka.mipt.ru>
References: <200804052156.05318.rusty@rustcorp.com.au> <20080405130647.GA21337@2ka.mipt.ru> <200804061320.59485.rusty@rustcorp.com.au> <20080406092018.GA32293@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49032 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbYDFNcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 09:32:32 -0400
Content-Disposition: inline
In-Reply-To: <20080406092018.GA32293@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Apr 06, 2008 at 01:20:18PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Actually I'm not that opposed agains additional destructor, I just want
> to bring attention to this topic, since this is second time some steps
> are going to be setup for the destruction time, so I want a clear
> solution :)

Actually the question is who is allowed to set that callback?
Essentially what I want is to get the same notifications as you propose
in patch 4 but for socket layer. AFAICS this will not collide with
tun/tap skbs.

-- 
	Evgeniy Polyakov
