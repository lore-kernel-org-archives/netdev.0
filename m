From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH] can: c_can: Do basic c_can configuration _before_
 enabling the interrupts
Date: Mon, 21 Mar 2011 15:49:17 +0100
Message-ID: <20110321144917.GA6791@e-circ.dyndns.org>
References: <1300715258.2010.30.camel@moestavern>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bhupesh.sharma@st.com, davem@davemloft.net,
	b.spranger@linutronix.de, netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:18744 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463Ab1CUOtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 10:49:22 -0400
Content-Disposition: inline
In-Reply-To: <1300715258.2010.30.camel@moestavern>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 02:47:38PM +0100, Jan Altenberg wrote:
> Hi all,
> 
> I ran into some trouble while testing the SocketCAN driver for the BOSCH
> C_CAN controller. The interface is not correctly initialized, if I put
> some CAN traffic on the line, _while_ the interface is being started
> (which means: the interface doesn't come up correcty, if there's some RX
> traffic while doing 'ifconfig can0 up').
> 
> The current implementation enables the controller interrupts _before_
> doing the basic c_can configuration. I think, this should be done the
> other way round.
The existing code indeed is susceptible for the decribed scenario.
> 
> The patch below fixes things for me.
Simple & good patch!
> 
> Signed-off-by: Jan Altenberg <jan@linutronix.de>
Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
