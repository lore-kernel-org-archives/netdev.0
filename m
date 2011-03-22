From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: c_can: Do basic c_can configuration _before_
 enabling the interrupts
Date: Mon, 21 Mar 2011 18:19:35 -0700 (PDT)
Message-ID: <20110321.181935.242136690.davem@davemloft.net>
References: <1300715258.2010.30.camel@moestavern>
	<4D877E61.5080703@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan@linutronix.de, bhupesh.sharma@st.com, b.spranger@linutronix.de,
	netdev@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41638
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755227Ab1CVBS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:18:58 -0400
In-Reply-To: <4D877E61.5080703@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Mon, 21 Mar 2011 17:35:45 +0100

> On 03/21/2011 02:47 PM, Jan Altenberg wrote:
>> Hi all,
>> 
>> I ran into some trouble while testing the SocketCAN driver for the BOSCH
>> C_CAN controller. The interface is not correctly initialized, if I put
>> some CAN traffic on the line, _while_ the interface is being started
>> (which means: the interface doesn't come up correcty, if there's some RX
>> traffic while doing 'ifconfig can0 up').
>> 
>> The current implementation enables the controller interrupts _before_
>> doing the basic c_can configuration. I think, this should be done the
>> other way round.
>> 
>> The patch below fixes things for me.
>> 
>> Signed-off-by: Jan Altenberg <jan@linutronix.de>
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks everyone.
