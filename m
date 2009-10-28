From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: phylib printouts
Date: Wed, 28 Oct 2009 17:33:19 +0100
Message-ID: <4AE8724F.3010104@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:42643 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755138AbZJ1Qfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 12:35:55 -0400
Received: from [192.168.0.35] (c-10a5e155.260-1-64736c10.cust.bredbandsbolaget.se [85.225.165.16])
	(authenticated bits=0)
	by mail176c2.megamailservers.com (8.13.6/8.13.1) with ESMTP id n9SGZuIL005966
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 12:35:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There are some printouts in the phy abstraction library using pr_info(). 
  Personally I would prefer if they used pr_debug() instead.

Especially the pr_info("%s: probed\n", bus->name) in mdiobus_register() 
since in some cases I can't tolerate a console printout while the link 
is down (we have an ethernet debug link and read the UART output through 
the link).

Of course this is a very specific case but in general in embedded 
systems (which I think is where the phylib is mainly used) I prefer the 
driver and other kernel code to be rather silent if not debugging.

Any opinions? :)

Best regards,
Kristoffer Glembo
