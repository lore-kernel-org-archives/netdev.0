From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: revert jumbo ringsize
Date: Thu, 29 Jan 2009 16:05:27 -0800 (PST)
Message-ID: <20090129.160527.32239609.davem@davemloft.net>
References: <1233261028-27584-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40442
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753728AbZA3AF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:05:29 -0500
In-Reply-To: <1233261028-27584-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu, 29 Jan 2009 12:30:28 -0800

> Reducing jumbo ring size below 1024 reduces throughput for old
> firmwares (3.4.216 and older) running on older (NX2031) chip,
> so restore it back to 1024.
> 
> This was reduced in commit 32ec803348b4d5f1353e1d7feae30880b8b3e342.
> 
> Raising jumbo ring size from 512 to 1024, adds ~4MB per port, but
> there's still big saving because of original patch (~20MB per port).
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, thanks.
