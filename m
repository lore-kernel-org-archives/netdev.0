From: Ben Greear <greearb@candelatech.com>
Subject: How is IPv6 dhcp supposed to work?
Date: Tue, 17 Jun 2014 14:41:43 -0700
Message-ID: <53A0B617.6070600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:46716 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964931AbaFQVlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 17:41:44 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 6904740A5C4
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 14:41:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to understand how DHCP for ipv6 is supposed to work.

I am able to get a global-scope address and prefix from
dhclient, but dhclient is not providing a gateway address.

I see the dhclient interface doing a Router Solicitation, but
I don't see any answers.

Are we supposed to run radvd or something like that as well?

Or is there some other automated magic that is supposed to
find the default gateway?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
