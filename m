From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: do not keep the GRE header around in collect
 medata mode
Date: Wed, 11 May 2016 15:17:41 -0400 (EDT)
Message-ID: <20160511.151741.532292838636551403.davem@davemloft.net>
References: <208ed3349bdc26bb9af1fe7e8ff64895e0e2c088.1462974784.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, simon.horman@netronome.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbcEKTRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 15:17:43 -0400
In-Reply-To: <208ed3349bdc26bb9af1fe7e8ff64895e0e2c088.1462974784.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 11 May 2016 15:53:57 +0200

> For ipgre interface in collect metadata mode, it doesn't make sense for the
> interface to be of ARPHRD_IPGRE type. The outer header of received packets
> is not needed, as all the information from it is present in metadata_dst. We
> already don't set ipgre_header_ops for collect metadata interfaces, which is
> the only consumer of mac_header pointing to the outer IP header.
> 
> Just set the interface type to ARPHRD_NONE in collect metadata mode for
> ipgre (not gretap, that still correctly stays ARPHRD_ETHER) and reset
> mac_header.
> 
> Fixes: a64b04d86d14 ("gre: do not assign header_ops in collect metadata mode")
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks Jiri.
