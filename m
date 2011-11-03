From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu, 3 Nov 2011 15:37:52 +0100
Message-ID: <20111103143752.GB7718@e-circ.dyndns.org>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
 <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
 <20111103100333.GD317@e-circ.dyndns.org>
 <4EB27026.90301@pengutronix.de>
 <4EB2A4DA.6040800@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:14847 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932077Ab1KCOh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 10:37:59 -0400
Content-Disposition: inline
In-Reply-To: <4EB2A4DA.6040800@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2011 at 03:27:38PM +0100, Oliver Hartkopp wrote:
> On 03.11.2011 11:42, Marc Kleine-Budde wrote:
> 
> > On 11/03/2011 11:03 AM, Kurt Van Dijck wrote:
> >> On Thu, Nov 03, 2011 at 10:47:53AM +0100, Marc Kleine-Budde wrote:
> >>> Hello,
> >>>
> >>> what about turning can_get_echo_skb() into a helper function which returns the number
> >>> of tx'ed bytes.
> >> That would work.
> >>
> >> Next step would be to do the statistics inside can_get_echo_skb(), but that's
> >> affecting all drivers using it ...
> >> Kurt
> > 
> > Interesting idea
> 
> 
> Yes, but then the name of the function is not appropriate anymore.
> 
> The return value for can_get_echo_skb() gives a silent improvement that can be
> adopted by CAN drivers by the time. But hiding more functionality inside this
> function may lead to misunderstandings.
That's what I described with the obscure phrase "..." :-)

Marc's proposed patch is indeed easier to digest at the time.
> 
Regards,
Kurt
