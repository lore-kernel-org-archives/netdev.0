From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC:  Support send-to-self over external interfaces (and veths).
Date: Mon, 11 Jun 2007 14:34:45 +0200
Message-ID: <466D4165.2090506@trash.net>
References: <4669ED81.8060800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41456 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbXFKMhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:37:12 -0400
In-Reply-To: <4669ED81.8060800@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> This should also be useful with the pending 'veth' driver, as it
> emulates two ethernet ports connected with a cross-over cable.
> 
> To make this work, you have to enable the sysctl (look Dave,
> no IOCTLS, there might be hope for me yet!! :)), and in your
> application you will need to use SO_BINDTODEVICE (and probably bind to
> the local IP as well).  Some applications such as traceroute already
> support this binding..others such as ping do not.
> 
> You most likely will also have to set up routing tables using
> source IPs as a rule to direct these connections to a particular
> routing table.
> 
> Comments welcome.


I would really prefer to simply make the prio 0 "lookup local"
rule deletable so you can rules with higher priority. That
allows to do send to self without any further code changes
and avoids the need to bind applications to a device.

