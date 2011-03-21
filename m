From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: c_can: Do basic c_can configuration _before_ enabling
 the interrupts
Date: Mon, 21 Mar 2011 17:35:45 +0100
Message-ID: <4D877E61.5080703@grandegger.com>
References: <1300715258.2010.30.camel@moestavern>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhupesh.sharma@st.com, davem@davemloft.net,
	b.spranger@linutronix.de, netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:51353 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab1CUQdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:33:37 -0400
In-Reply-To: <1300715258.2010.30.camel@moestavern>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2011 02:47 PM, Jan Altenberg wrote:
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
> 
> The patch below fixes things for me.
> 
> Signed-off-by: Jan Altenberg <jan@linutronix.de>

Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Thanks,

Wolfgang.
