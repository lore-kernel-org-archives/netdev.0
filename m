From: Willy Tarreau <w@1wt.eu>
Subject: Stable backport of 2 igb fixes
Date: Tue, 13 May 2014 11:59:21 +0200
Message-ID: <20140513095921.GC30843@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:35009 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736AbaEMJ7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 05:59:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

could we please have the following patches backported to stable :

  cb06d102327 igb: Fix Null-pointer dereference in igb_reset_q_vector
  b709323d247 igb: Unset IGB_FLAG_HAS_MSIX-flag when falling back to msi-only

This morning I experienced again that old kernel panic on 3.14.3 when
loading igb on an ARM board without them.

Thanks!
Willy
