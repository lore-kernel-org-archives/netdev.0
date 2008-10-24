From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Problem: ip_forward in 2.6.27 via realtek 8169 and rt2500pci needs mtu 185 on machines in LAN
Date: Fri, 24 Oct 2008 10:28:20 +0400
Message-ID: <20081024062820.GA9321@ioremap.net>
References: <490127D6.8080201@jsigle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Joerg M. Sigle" <joerg.sigle@jsigle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:57057 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbYJXG2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 02:28:22 -0400
Content-Disposition: inline
In-Reply-To: <490127D6.8080201@jsigle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joerg.

On Fri, Oct 24, 2008 at 03:41:42AM +0200, Joerg M. Sigle (joerg.sigle@jsigle.com) wrote:
> Linux box1
> eth0:192.168.1.1 (3com Vortex or so)
>   |
>   |    Linux Box2
>   |    eth0:192.168.1.4 (Ne2000 PCMCIA)
>   |      |
> SimpleSwitch
>   |
> eth0:192.168.1.40 (Realtek 8169 onboard)
> Linux routerbox (Plain vanilla 2.6.27 SMP)
> wlan0:192.168.2.40 (Ralink rt2500 PCI)
>   |
> USR8054 dedicated WLAN-Router
>   |
> Internet (or so).

Let me clarify the problem. Traffic fom linux clients only goes through
above setup if mtu on the USR8054 lan device is 185 bytes, correct?

Can you run network traffic with big mtu (normal 1500 bytes) between
linux router and clients? Between clients?

-- 
	Evgeniy Polyakov
