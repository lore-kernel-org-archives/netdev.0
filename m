From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: route non-local sources for raw socket
Date: Sun, 07 Aug 2011 22:53:58 -0700 (PDT)
Message-ID: <20110807.225358.367578942222395764.davem@davemloft.net>
References: <alpine.LFD.2.00.1108072212390.1423@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab1HHFyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:54:06 -0400
In-Reply-To: <alpine.LFD.2.00.1108072212390.1423@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 7 Aug 2011 22:16:09 +0300 (EEST)

> 
> 	The raw sockets can provide source address for
> routing but their privileges are not considered. We
> can provide non-local source address, make sure the
> FLOWI_FLAG_ANYSRC flag is set if socket has privileges
> for this, i.e. based on hdrincl (IP_HDRINCL) and
> transparent flags.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
