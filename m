From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option
 checking
Date: Sat, 07 Apr 2012 08:46:57 -0400 (EDT)
Message-ID: <20120407.084657.1719148601003380853.davem@davemloft.net>
References: <1333795467-3643-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751Ab2DGMuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 08:50:04 -0400
In-Reply-To: <1333795467-3643-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sat,  7 Apr 2012 12:44:27 +0200

> Added strict checking of PadN, which can be used to increase header
> size and thus push the protocol header into the 2nd fragment.
> 
> PadN is used to align the options within the Hop-by-Hop or
> Destination Options header to 64-bit boundaries. The maximum valid
> size is thus 7 bytes.
> RFC 4942 recommends to actively check the "payload" itself and
> ensure that it contains only zeroes.
> 
> See also RFC 4942 section 2.1.9.5.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

A sysctl _AND_ a kconfig option, give me a break, that's
pointless.

Either we want this or we don't.
