From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: make struct proto const
Date: Sun, 27 Mar 2011 18:14:14 -0700 (PDT)
Message-ID: <20110327.181414.260098631.davem@davemloft.net>
References: <4D88EA0D.3090601@hartkopp.net>
	<20110322190038.GA286@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57405
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1BOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:14:52 -0400
In-Reply-To: <20110322190038.GA286@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Tue, 22 Mar 2011 20:00:38 +0100

> On Tue, Mar 22, 2011 at 07:27:25PM +0100, Oliver Hartkopp wrote:
>> can_ioctl is the only reason for struct proto to be non-const.
>> script/check-patch.pl suggests struct proto be const.
>> 
>> Setting the reference to the common can_ioctl() in all CAN protocols directly
>> removes the need to make the struct proto writable in af_can.c
>> 
>> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>> 
> Good idea to take this apart from my J1939 series.

Applied, thanks.
