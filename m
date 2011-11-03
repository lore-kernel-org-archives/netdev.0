From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu, 3 Nov 2011 11:03:33 +0100
Message-ID: <20111103100333.GD317@e-circ.dyndns.org>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
 <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:36377 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754740Ab1KCKDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:03:36 -0400
Content-Disposition: inline
In-Reply-To: <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2011 at 10:47:53AM +0100, Marc Kleine-Budde wrote:
> Hello,
> 
> what about turning can_get_echo_skb() into a helper function which returns the number
> of tx'ed bytes.
That would work.

Next step would be to do the statistics inside can_get_echo_skb(), but that's
affecting all drivers using it ...
Kurt

> 
> Marc
> 
> 
