From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Handling set_mac_address in set_rx_mode
Date: Sat, 30 Jun 2007 16:38:13 -0400
Message-ID: <4686BF35.8080605@garzik.org>
References: <4686A614.1000709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38161 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbXF3UiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 16:38:15 -0400
In-Reply-To: <4686A614.1000709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> While adding support for secondary unicast addresses to 8021q and
> macvlan, I've tried keeping dev->dev_addr as global address on
> dev->uc_list and have drivers skip them to avoid having all
> dev_unicast_add users implement a state machine like this:

[...]

Something that is not entirely clear to me...  This has zero impact on 
existing drivers, right?

I would not fancy updating all drivers for a new MAC addr scheme...

	Jeff



