From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb4: fix MAC address hash filter
Date: Wed, 08 Dec 2010 09:36:32 -0800 (PST)
Message-ID: <20101208.093632.246520500.davem@davemloft.net>
References: <1291408744-2392-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754304Ab0LHRgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 12:36:05 -0500
In-Reply-To: <1291408744-2392-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Fri,  3 Dec 2010 12:39:04 -0800

> Fix the calculation of the inexact hash-based MAC address filter.
> It's 64 bits but current code is missing a ULL.  Results in filtering out
> some legitimate packets.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied, thanks.
