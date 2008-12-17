From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Re: Bonding gigabit and fast?
Date: Wed, 17 Dec 2008 07:51:55 +0000
Message-ID: <200812170751.55999.tvrtko@ursulin.net>
References: <200812161939.30033.tvrtko@ursulin.net> <Pine.LNX.4.64.0812161331270.28806@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-6-a-2.mail.uk.tiscali.com ([212.74.114.16]:17765
	"EHLO mk-outboundfilter-6-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758966AbYLQHv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 02:51:58 -0500
In-Reply-To: <Pine.LNX.4.64.0812161331270.28806@t2.domain.actdsltmp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 December 2008 02:53:10 Trent Piepho wrote:
> If the transmitter is sending out packets round-robin on two links, it's
> sending the packets like this:
>
> Link A:  1   3   5   7
> Link B:    2   4   6   8
>
> If the cards return two packets per interrupt, the receiver gets them like
> this:
>
> Link A:  1 3     5 7
> Link B:      2 4     6 8
>
> Well, the Linux kernel does not like getting the packets in the order (1 3
> 2 4 5 7 6 8).  It likes to get the packets in the correct order.  And so
> performance suffers.  At the time, it suffered greatly.  Maybe it's better
> or worse now?

I don't know, but to clarify I was never aiming to get higher than gigabit 
speed, even on the receiver side there is only single gigabit link. From the 
bonding HOWTO I understood that in this configuration packets my actually 
arrive in order.

Point of my experiment was to see if I can work around very slow gigabit 
speeds (<10Mb/s) I was getting while serving data out with Samba. So I was 
hoping to get 20 Mb/s sustained with this slow gigabit and normally fast fast 
ethernet. But yeah, bonding seemed to cause aggregated speed to be somewhat 
less than when each were alone.

Tvrtko
