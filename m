From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Wed, 11 Dec 2013 12:26:37 -0800
Message-ID: <20131211122637.75b09074@nehalam.linuxnetplumber.net>
References: <52A75EF8.3010308@in.tum.de>
	<20131211.150137.368953964178408437.davem@davemloft.net>
	<52A8C8B4.4060109@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org, jacob@appelbaum.net
To: Christian Grothoff <grothoff@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46221 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab3LKU0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:26:41 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so10662658pbc.39
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 12:26:40 -0800 (PST)
In-Reply-To: <52A8C8B4.4060109@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Dec 2013 21:19:00 +0100
Christian Grothoff <grothoff@in.tum.de> wrote:

> On 12/11/2013 09:01 PM, David Miller wrote:
> > From: Christian Grothoff <grothoff@in.tum.de>
> > Date: Tue, 10 Dec 2013 19:35:36 +0100
> > 
> >> Only NAT implementations that change the SQN are not supported
> >> (those should be rare, but we have no hard data on this).
> > 
> > Even Linux's netfilter can and does do this, it is absolutely necessary
> > for tracking SIP and FTP protocols, and it's also used in our virtual
> > server load balancing modules.
> > 
> 
> We're aware that Linux _can_ do this.  I was not aware it was doing this
> for
> SIP and FTP specifically; regardless, what implementations can do is less
> important than what they are configured to do most of the time, and that's
> what we'd need hard data on.  Anyway, I'd be very interested to learn how
> you use this for SIP/FTP to evaluate the impact.  Do you have documentation
> on this?
> 
> As for server load balancing, I suspect that those are not the kinds of
> services that one would typically use port knocking for.  Still, again a
> good hint as to where trouble might lurk (and we will definitively include
> those points in the next revision of the documentation).

The point is that doing it outside of TCP core is safer, less error prone
and more flexible.
