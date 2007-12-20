From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 2/9] SCTP: Handle the wildcard ADD-IP Address
 parameter
Date: Thu, 20 Dec 2007 14:09:03 -0800 (PST)
Message-ID: <20071220.140903.240338337.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764539AbXLTWJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:09:04 -0500
In-Reply-To: <1197927169-5106-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:42 -0500

> The Address Parameter in the parameter list of the ASCONF chunk
> may be a wildcard address.  In this case special processing
> is required.  For the 'add' case, the source IP of the packet is
> added.  In the 'del' case, all addresses except the source IP
> of packet are removed. In the "mark primary" case, the source
> address is marked as primary.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
