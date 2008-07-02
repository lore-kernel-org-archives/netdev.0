From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] pasemi_mac: Access iph->tot_len with correct endianness
Date: Tue, 1 Jul 2008 23:24:26 -0500
Message-ID: <20080702042426.GA27717@lixom.net>
References: <ada63rpecyi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38401 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbYGBEHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 00:07:48 -0400
Content-Disposition: inline
In-Reply-To: <ada63rpecyi.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2008 at 10:22:45AM -0700, Roland Dreier wrote:
> iph->tot_len is stored in network byte order, so access it using
> ntohs().  This doesn't have any real world impact on pasemi_mac, since
> the device only exists as part of a big-endian system-on-chip, but
> fixing this gets rid of a sparse warning and avoids having a bad example
> in the tree.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Acked-by: Olof Johansson <olof@lixom.net>
