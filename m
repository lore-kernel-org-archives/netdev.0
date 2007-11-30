From: Michael Blizek <michi1@michaelblizek.homelinux.net>
Subject: Re: Does tc-prio really work as advertised?
Date: Fri, 30 Nov 2007 19:39:46 +0100
Message-ID: <20071130183946.GB2368@grml.local>
References: <759014.71791.qm@web51409.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Pommnitz <pommnitz@yahoo.com>,
	Jarek Poplawski <jarkao2@o2.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from michaelblizek.homelinux.net ([193.238.157.55]:59355 "EHLO
	michaelblizek.homelinux.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762813AbXK3TLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 14:11:36 -0500
Content-Disposition: inline
In-Reply-To: <759014.71791.qm@web51409.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

On 05:00 Tue 27 Nov     , Joerg Pommnitz wrote:
> > So, are you still sure you've tested such a case?
> 
> Well, the problem that triggered my investigation was
> that the OLSR daemon (www.olsr.org) calculates the quality
> of a link according to the packet loss for LQ HELLO packets
> (UDP broadcast packets). To prevent other traffic from
> interfering with the LQ calculation, olsrd sends the HELLO
> packets with a TOS value of 0x10 (minimize delay). This
> should give them the highest priority.
> 
> What I saw was a degrading Link quality with more user traffic
> over a link. The LQ fell so far that olsrd judged the other host
> unreachable and deleted the routing entry. The user traffic in
> question was iperf (TOS value 0x00).
> --  
> Regards and thanks for taking an interest
> 
>  
>        Joerg

There is another possible cause of this problem.

In WLANs all packets are acked or retransmitted. This is done to
prevent packet loss due to noise and collisions. But this is not
done with broadcast packets.

I can't tell you if this can be enough to trigger the bevaviour
you experienced. Is the signal barely receivable?

Michi
-- 
programing a layer 3+4 network protocol for mesh networks
see http://michaelblizek.homelinux.net

