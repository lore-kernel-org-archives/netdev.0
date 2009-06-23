From: Joe Perches <joe@perches.com>
Subject: Re: net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit()
 functions
Date: Tue, 23 Jun 2009 09:21:28 -0700
Message-ID: <1245774088.29098.10.camel@Joe-Laptop.home>
References: <4A40FCBC.9040700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3031 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbZFWQVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 12:21:47 -0400
In-Reply-To: <4A40FCBC.9040700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-06-23 at 18:03 +0200, Patrick McHardy wrote:
> This patch is the result of an automatic spatch transformation to
> convert all ndo_start_xmit() return values of 0 to NETDEV_TX_OK.

It might be useful if you submitted the spatch source
that created this transformation.

