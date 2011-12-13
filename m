From: David Miller <davem@davemloft.net>
Subject: Re: bayom_epp patch
Date: Tue, 13 Dec 2011 16:11:52 -0500 (EST)
Message-ID: <20111213.161152.2177839675233365658.davem@davemloft.net>
References: <1323777960.12740.2.camel@xbox360.hq.axsem.com>
	<4EE748BA.5080807@suse.cz>
	<1323802208.12740.5.camel@xbox360.hq.axsem.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sailer@sailer.dynip.lugs.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab1LMVL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 16:11:59 -0500
In-Reply-To: <1323802208.12740.5.camel@xbox360.hq.axsem.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Sailer <sailer@sailer.dynip.lugs.ch>
Date: Tue, 13 Dec 2011 19:50:08 +0100

> baycom_epp: Improve parport handling, fix multi-core support

This is a really sloppily coded patch, there is tons of
trailing whitespace and damaged initial tabs mixed with
space characters:

+ git apply --check --whitespace=error-all diff
diff:428: space before tab in indent.
 	spin_unlock_bh(&bc->lock);
diff:436: trailing whitespace.
	
diff:439: trailing whitespace.
		
diff:487: trailing whitespace.
	/* prepare EPP mode; we aren't using interrupts */		
diff:539: trailing whitespace.
	spin_unlock_bh(&bc->lock);	
diff:779: trailing whitespace.
		
Please fix this up and freshly resubmit.
