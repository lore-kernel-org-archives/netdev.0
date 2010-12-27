From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Bypass flow control problems
Date: Mon, 27 Dec 2010 15:43:46 +0200
Message-ID: <20101227134346.GD2754@reaktio.net>
References: <1293040291.1777.36.camel@alkis>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alkis Georgopoulos <alkisg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:47142 "EHLO
	vulpes-int.media.sonera.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753880Ab0L0OTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Dec 2010 09:19:37 -0500
Received: from smtp.tele.fi (smtp.tele.fi [192.89.123.25])
	by vulpes-int.media.sonera.net (Postfix) with ESMTP id 04BB836BC
	for <netdev@vger.kernel.org>; Mon, 27 Dec 2010 15:44:18 +0200 (EET)
Content-Disposition: inline
In-Reply-To: <1293040291.1777.36.camel@alkis>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 22, 2010 at 07:51:31PM +0200, Alkis Georgopoulos wrote:
> Hi,
> 
> I'm an IT teacher/LTSP developer. In LTSP, thin clients are netbooted
> from a server and receive a lot of X and remote disk traffic from it.
> 
> Many installations have a gigabit NIC on the server, an unmanaged
> gigabit switch, and 100 Mbps NICs on the clients.
> 
> With flow control on, the server is limited to sending 100 Mbps to all
> the clients. So with 10 thin clients the server can concurrently send
> only 10 Mbps to each one of them.
> 
> On NICs that support it, we turn flow control off and the server can
> properly send 100 Mbps to each client, i.e. 1 Gbps to 10 clients.
> 
>  * Is there any way to bypass that problem on NICs that do not support
>    turning off flow control, like e.g. realteks?
>    I.e. when a client sends a pause signal to the server, instead of the
>    server pausing, to continue sending data to another client?
>    Or even to limit the amound of data the server sends to each client,
>    so that the clients never have to send pause signals?
> 

You could set up QoS rules on the server to limit the network speed per client..

>  * I really don't understand why flow control is enabled by default on
>    NICs and switches. In which case does it help? As far as I
>    understand, all it does is ruin gigabit => 100 Mbps connections...
> 
>  * As a side note, since rtl8169 is a very common chipset, is there a
>    way to disable flow control for that specific NIC?
> 
> This problem affects thousands of LTSP installations, we'd much
> appreciate your knowledge and feedback on it.
> 

Did you try disabling flow control from the switch? 

-- Pasi

