From: David Miller <davem@davemloft.net>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 05:53:33 -0800 (PST)
Message-ID: <20080130.055333.192844925.davem@davemloft.net>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, henning.fehrmann@aei.mpg.de,
	carsten.aulbert@aei.mpg.de, bruce.allen@aei.mpg.de,
	netdev@vger.kernel.org
To: ballen@gravity.phys.uwm.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756011AbYA3NxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 08:53:14 -0500
In-Reply-To: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Date: Wed, 30 Jan 2008 03:51:51 -0600 (CST)

[ netdev@vger.kernel.org added to CC: list, that is where
  kernel networking issues are discussed. ]

> (The performance of a full duplex stream should be close to 1Gb/s in
> both directions.)

This is not a reasonable expectation.

ACKs take up space on the link in the opposite direction of the
transfer.

So the link usage in the opposite direction of the transfer is
very far from zero.
