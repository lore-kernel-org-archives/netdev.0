From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode
 IP_PMTUDISC_INTERFACE
Date: Tue, 29 Oct 2013 15:38:38 -0400 (EDT)
Message-ID: <20131029.153838.825609236199228090.davem@davemloft.net>
References: <20131026201158.GI15744@order.stressinduktion.org>
	<20131029.000844.1092862708536984032.davem@davemloft.net>
	<526F6583.4000506@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab3J2Tim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:38:42 -0400
In-Reply-To: <526F6583.4000506@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Weimer <fweimer@redhat.com>
Date: Tue, 29 Oct 2013 08:36:35 +0100

> You could make the path MTU dependent on the protocol (which would
> even be the correct solution from a technical point of view) and use
> validation for TCP and UDP, but that's a fairly invasive change for
> such relatively minor functionality.

The code pretty much already does this, we cannot even find the
exact route without being able to look up the socket right now.
We need the full flow info.

There is a backup path, but you could make the new (non-default)
behavior be to never trust that path for protocols like UDP and
TCP.

I don't buy any of your arguments against my suggestions so far.
