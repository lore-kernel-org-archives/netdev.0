From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] via-velocity: add netpoll functionality for the benefit
 of netconsole
Date: Tue, 05 Jan 2010 21:19:33 +0100
Message-ID: <4B439ED5.0@computer.org>
References: <4B423440.6060807@computer.org> <20100105072800.13dba6d2@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?St=E9phane_Berthelot?= <sberthelot@emisfr.com>
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:33926 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754704Ab0AEUYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 15:24:07 -0500
In-Reply-To: <20100105072800.13dba6d2@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Kagstrom wrote:
> Does the patch still work with the new NAPI support in the driver?

Errr. (Is my ignorance showing yet?)

I will have to study this, based on other drivers and your commit dfff71.

I would be grateful for any hints, but otherwise will endeavour to figure it out myself.

>> +static void velocity_poll_controller(struct net_device *dev)
>> +{
>> +	disable_irq(dev->irq);
>> +	velocity_intr(dev->irq, dev);
>> +	enable_irq(dev->irq);
>> +}
> 
> This should probably have an
> 
> #ifdef CONFIG_NET_POLL_CONTROLLER
> ...
> #endif
> 
> around it

You are right, will add.


Thanks, Jan
