From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH] can: make struct proto const
Date: Tue, 22 Mar 2011 20:00:38 +0100
Message-ID: <20110322190038.GA286@e-circ.dyndns.org>
References: <4D88EA0D.3090601@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:17331 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752626Ab1CVTAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 15:00:41 -0400
Content-Disposition: inline
In-Reply-To: <4D88EA0D.3090601@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 07:27:25PM +0100, Oliver Hartkopp wrote:
> can_ioctl is the only reason for struct proto to be non-const.
> script/check-patch.pl suggests struct proto be const.
> 
> Setting the reference to the common can_ioctl() in all CAN protocols directly
> removes the need to make the struct proto writable in af_can.c
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
Good idea to take this apart from my J1939 series.
Kurt
