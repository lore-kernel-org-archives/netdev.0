From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Recent change to net-next broke KVM bridging
Date: Wed, 17 Feb 2010 15:26:02 +0100
Message-ID: <201002171526.02493.arnd@arndb.de>
References: <20100216173658.519b6245@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50585 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab0BQO0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 09:26:15 -0500
In-Reply-To: <20100216173658.519b6245@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 February 2010, Stephen Hemminger wrote:
> Something in net-next tree broke bridging of virtual nets.
> My local VM's can no longer access external networks.

Is that using tun/tap devices to access the bridge or something else?
Do you know if an older net-next version on top of 2.6.33-rc was still
working?

The only patch I've seen in that area is 05c2828c7 "tun: export
underlying socket", but that seems harmless.

	Arnd
