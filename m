From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: IPv6 default routes timing out?
Date: Thu, 30 Jul 2009 20:09:15 +0000
Message-ID: <1248984555.8639.4.camel@Maple>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
	 <1248914038.13447.17.camel@merlyn>
	 <87k51q6raq.fsf@shaolin.home.digitalvampire.org>
	 <1248975058.7167.28.camel@Maple>  <aday6q6qatu.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@digitalvampire.org>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f203.google.com ([209.85.216.203]:61461 "EHLO
	mail-px0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbZG3UJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:09:19 -0400
Received: by pxi41 with SMTP id 41so500145pxi.33
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 13:09:19 -0700 (PDT)
In-Reply-To: <aday6q6qatu.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-30 at 11:34 -0700, Roland Dreier wrote:
> Well, I see router advertisements (and pings to ff02::1) from the router
> on both of the two laptops I have handy, and then after a while the
> openbsd system seems to stop broadcasting -- I no longer see the
> broadcast ipv6 packets on either laptop, but if I just do "ifconfig ral0
> down; ifconfig ral0 up" on the openbsd system then everything seems to
> come back.

Note that these are actually multicasts, not broadcasts.  There's not
much difference on the sending end, but on the receiving end there's
usually filtering at the NIC level that doesn't apply to broadcasts.

That's why I'm a little bit suspicious of the laptop end of your
connection.  It's not uncommon for multicast to be broken in various
ways without people noticing, because they don't use it very much on
IPv4.  However, it's fundamental to IPv6.

  --  John 

