From: Brian Haley <brian.haley@hp.com>
Subject: Re: Source routing without rules?
Date: Tue, 27 Aug 2013 20:57:33 -0400
Message-ID: <521D4AFD.2000102@hp.com>
References: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9412 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab3H1A5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 20:57:35 -0400
In-Reply-To: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2013 08:16 PM, Andy Lutomirski wrote:
> I'm about to implement a trivial source routing policy for the third
> time, and this is IMO stupid.  I want to have two routes to a network.
>  Each route should specify a src, and, if the flow matches the src,
> then that route should win.
> 
> The rules that don't work are:
> 
> ip route add <net> via <gw1> dev <dev1> metric 0
> ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10
> 
> Even if I bind a socket to dev2addr, the outgoing packets go out dev1
> to gw1.  This is exactly what I don't want to have happen.

Look at this page on routing rules:

http://lartc.org/howto/lartc.rpdb.html

-Brian
