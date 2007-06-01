From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/5] VLAN driver API fixes
Date: Fri, 01 Jun 2007 19:12:28 +0200
Message-ID: <4660537C.6060307@trash.net>
References: <20070601164356.673375550@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jeff Garzk <jgarzik@pobox.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36495 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908AbXFAROF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 13:14:05 -0400
In-Reply-To: <20070601164356.673375550@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Patrick's fix for sky2 VLAN unregister, started me looking at
> other drivers. Many drivers had bogus kill_vid hooks, and the whole
> interface for kill_vid is only useful for devices that do receive
> filtering, so fix the interface and the drivers.


Looks good too me.
