From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH 12/16] ipv4: Maintain redirect and PMTU info in struct
 rtable again.
Date: Tue, 17 Jul 2012 14:12:45 -0400
Message-ID: <20120717181245.GA8146@d2.synalogic.ca>
References: <20120710.080746.694016763983176902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36369 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756167Ab2GQSMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 14:12:50 -0400
Content-Disposition: inline
In-Reply-To: <20120710.080746.694016763983176902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012/07/10 08:07, David Miller wrote:
> 
> Maintaining this in the inetpeer entries was not the right way to do
> this at all.
> 

This patch makes it possible to have the same address assigned to a tunnel
interface and its lower device, whereas previously that would lead to mtu
problems because both routes shared the same pmtu info in the inet_peer.

ex: gre1 192.168.1.2/32 over eth0 192.168.1.2/24

Is such a wicked configuration supported?
