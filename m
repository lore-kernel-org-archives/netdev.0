From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [IrDA] af_irda: irda_recvmsg_stream cleanup
Date: Fri, 20 Apr 2007 22:05:39 -0700 (PDT)
Message-ID: <20070420.220539.28795558.davem@davemloft.net>
References: <20070418213202.214829666@sortiz.org>
	<20070418214750.230933366@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	olaf.kirch@oracle.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55773
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbXDUFFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:05:37 -0400
In-Reply-To: <20070418214750.230933366@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Thu, 19 Apr 2007 00:32:03 +0300

> From: Olaf Kirch <olaf.kirch@oracle.com>
> 
> This patch cleans up some code in irda_recvmsg_stream, replacing some
> homebrew code with prepare_to_wait/finish_wait, and by making the
> code honor sock_rcvtimeo.
> 
> Signed-off-by: Olaf Kirch <olaf.kirch@oracle.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied to net-2.6.22, thanks.
