From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] CPU lockup detected
Date: Wed, 17 Oct 2007 18:41:09 +0200
Message-ID: <47163B25.9060701@trash.net>
References: <20071017083554.5a4e1f16@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tore@linpro.no
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44675 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbXJQQlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 12:41:15 -0400
In-Reply-To: <20071017083554.5a4e1f16@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please CC either Bug submitter or bugzilla on forwarded
reports.

Stephen Hemminger wrote:
> Possible suspects TCP MD5 and/or netfilter conntrack.

Conntrack is very unlikely, it has already completely exited
the netfilter codepath when the packet reaches TCP.
