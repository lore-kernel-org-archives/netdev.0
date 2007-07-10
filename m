From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e100: Fix Tyan motherboard e100 not receiving IPMI commands
Date: Tue, 10 Jul 2007 12:26:38 -0400
Message-ID: <4693B33E.1020306@garzik.org>
References: <20070710154511.8419.38789.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.graham@intel.com, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60001 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761004AbXGJQ0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:26:40 -0400
In-Reply-To: <20070710154511.8419.38789.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: David Graham <david.graham@intel.com>
> 
> The 82550 & 51 parts have an extended configuration block that
> includes a bit "GMRC", required to enable the expected TCO behavior,
> in config byte offset 22d.  The config block sent by the failing driver
> does include the extension area, but this bit is not initialised,
> and the downlaod only specifies 0x16 bytes to be sent to the NIC
> (thaht's bytes 00..21d). By initializing the GMRC bit, and extending
> the download size for D102+ MACs, the problem is resolved.
> 
> Signed-off-by: David Graham <david.graham@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e100.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)

applied


